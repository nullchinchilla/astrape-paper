#lang racket
(require plot
         plot/no-gui)

(define (n->prob n hfrac)
  (expt (- 1 hfrac) n))

(define (prob->n p f)
  (/ (log (- 1 p))
     (log (- 1 f))))

(define (n->size n)
  (+ (* 56 n n) 120))

(parameterize ([plot-y-transform log-transform]
               [plot-y-ticks (log-ticks)]
               [plot-font-face "TeX Gyre Termes"]
               [plot-font-size 14])
  (plot-file
   (for/list ([n (in-range 3 20 5)])
     (function (λ (f)
                 (n->prob n (- 1 f)))
               #:color n
               #:label
               (format "n = ~a; size = ~a"
                       n
                       (n->size n))))
   "corruptfrac.pdf"
   #:x-min 0.1
   #:x-max 0.9
   #:legend-anchor 'bottom-right
   #:x-label "fraction of corrupt users"
   #:y-label "chance of anonymity violation"))