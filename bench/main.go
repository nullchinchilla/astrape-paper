package main

import (
	"bytes"
	"crypto/rand"
	"crypto/sha256"
	"log"
	"time"
)

func setupHTLC(n int) []byte {
	// just a hash of a rando
	r := make([]byte, 32)
	rand.Read(r)
	i := sha256.Sum256(r)
	j := sha256.Sum256(i[:])
	return j[:]
}

func setupAstrape(n int) [][]byte {
	// first generate n randos
	r := make([][]byte, n)
	for i := 0; i < n; i++ {
		ri := make([]byte, 32)
		rand.Read(ri)
		r[i] = ri
	}
	// then generate xi
	x := make([][]byte, n)
	ps := make([][]byte, n)
	for i := len(x) - 1; i >= 0; i-- {
		oi := make([]byte, 32)
		rand.Read(oi)
		if i == len(x)-1 {
			z := sha256.Sum256(oi)
			x[i] = z[:]
			ps[i] = r[i]
		} else {
			ps[i] = make([]byte, 32)
			for j := range r[i] {
				ps[i][j] = r[i][j] ^ ps[i+1][j]
			}
			si := sha256.Sum256(ps[i])
			si1 := sha256.Sum256(ps[i+1])
			buf := new(bytes.Buffer)
			buf.Write(r[i])
			buf.Write(si[:])
			buf.Write(si1[:])
			buf.Write(oi)
			buf.Write(x[i+1])
			x[i] = buf.Bytes()
		}
	}
	return x
}

func main() {
	const RND = 10000

	// HTLC
	start := time.Now()
	for i := 0; i < RND; i++ {
		setupHTLC(0)
	}
	log.Println(RND, "HTLC setups took", time.Since(start))
	// Astrape
	start = time.Now()
	for i := 0; i < RND; i++ {
		setupAstrape(100)
	}
	log.Println(RND, "Astrape(10) setups took", time.Since(start))
}
