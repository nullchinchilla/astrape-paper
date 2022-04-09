#lang racket
(require json
         graph
         plot
         data-frame)

(define raw-data
  (with-input-from-file "networkgraphv2.json"
    read-json))

(define edges
  (for/list ([v (hash-ref raw-data 'edges)])
    (list (hash-ref v 'node1_pub)
          (hash-ref v 'node2_pub))))

;; first define a graph
(define G (unweighted-graph/undirected edges))
(define nodes (sequence->list (in-vertices G)))
(printf "graph with ~a nodes loaded\n" (length nodes))
;; randomly sample some node pairs
(define pairs
  (for/list ([x (shuffle nodes)]
             [y (shuffle nodes)]
             [c 5000])
    (list x y)))
(printf "~a pairs\n" (length pairs))

(define hitcounts (make-hash))
(define cpuover (make-hash))
(define commover (make-hash))

(define (hash-incr! hsh val incr)
  (hash-set! hsh val (+ incr (hash-ref hsh val 0))))

;; distances
(define distances
  (for/list ([p pairs]
             [c (in-naturals)])
    (printf "processing ~a\n" c)
    (let ([path (fewest-vertices-path G (first p)
                                      (second p))])
      (when path
        (define N (length path))
        (for ([nd path])
          (hash-incr! hitcounts nd 1)
          (hash-incr! cpuover nd (* 0.7 N))
          (hash-incr! commover nd (/ (+ (* 192 N)
                                        (+ 103 (* 40 N)))
                                     1024.0)))) 
      (if path (length path) -1))))

(define (generate-hist data)
  (sort
    (for/list ([(k v)
                (let loop ([dist data])
                  (cond
                    [(empty? dist) (hash)]
                    [else (define rst (loop (cdr dist)))
                          (hash-set rst (car dist)
                                    (add1 (hash-ref rst (car dist) 0)))]))])
      (list k v))
    (lambda (a b)
      (< (car a)
         (car b)))))

(define distance-histogram
  (filter
   (lambda (x) (> (car x) 0))
   (generate-hist distances)))

(define (hist->cdf hist)
  (define acc 0)
  (define lst
    (for/list ([z hist])
      (match z
        [(list a b)
         (set! acc (+ acc b))
         (list a acc)])))
  (for/list ([e lst])
    (match e
      [(list a b)
       (list a (/ (exact->inexact b) acc))])))
                   

;; plot distance histogram
(plot (discrete-histogram distance-histogram)
      #:x-label "Number of hops"
      #:y-label "Count")

(define (list->csv lst)
  (with-output-to-string (lambda()
                           (for ([ele lst])
                             (printf "~a,\n" ele)))))

(define (log-lin-ticks)
  (ticks (log-ticks-layout)
         (linear-ticks-format)))

(with-output-to-file "hitcounts.csv"
  #:exists 'replace
  (lambda()
    (displayln
     (list->csv
      (append* (map (λ(x)
                      (match x [(list a b) (make-list b a)]))
                    (generate-hist (map cdr (hash->list hitcounts)))))))))

(with-output-to-file "cpuover.csv"
  #:exists 'replace
  (lambda()
    (displayln
     (list->csv
      (append* (map (λ(x)
                      (match x [(list a b) (make-list b a)]))
                    (generate-hist (map cdr (hash->list cpuover)))))))))

(with-output-to-file "commover.csv"
  #:exists 'replace
  (lambda()
    (displayln
     (list->csv
      (append* (map (λ(x)
                      (match x [(list a b) (make-list b a)]))
                    (generate-hist (map cdr (hash->list commover)))))))))


#|
(parameterize ([plot-y-transform log-transform]
               [plot-y-ticks (log-lin-ticks)])
  (plot (lines (hist->cdf (generate-hist (map cdr (hash->list hitcounts)))))
        #:x-label "Hit count"
        #:y-label "Cumulative probability"
        #:x-min 0.001))

(plot (lines (hist->cdf (generate-hist (map cdr (hash->list cpuover)))))
      #:x-label "Total CPU time (ms)"
      #:y-label "Cumulative probability"
      #:x-min 0.001)


(plot (lines (hist->cdf (generate-hist (map cdr (hash->list commover)))))
      #:x-label "Total communication overhead (BCH, KiB)"
      #:y-label "Cumulative probability"
      ;#:x-min 1
      )

(plot (density (append* (map (λ(x)
                               (match x [(list a b) (make-list b a)]))
                             (generate-hist (map cdr (hash->list hitcounts)))))))

(parameterize ([plot-y-transform log-transform]
               [plot-y-ticks (log-lin-ticks)])
  (plot (discrete-histogram (generate-hist (map cdr (hash->list hitcounts))))
         #:y-min 0.7))|#
