## Astrape: Anonymous Payment Channels with Boring Cryptography (extended version)

**Abstract**: The increasing use of blockchain-based cryptocurrencies like Bitcoin has run into inherent scalability limitations of blockchains. Payment channel networks, or PCNs, promise to greatly increase scalability by conducting the vast majority of transactions outside the blockchain while leveraging it as a final settlement protocol. Unfortunately, first-generation PCNs have significant flaws in privacy. In particular, even though transactions are conducted off-chain, anonymity guarantees are very weak.

In this work, we present Astrape, a novel PCN construction that achieves strong security and anonymity guarantees with simple, black-box cryptography, given a blockchain with flexible scripting. Existing anonymous PCN constructions often integrate with specific, often custom-designed, cryptographic construction. But at a slight cost to asymptotic performance, Astrape can use any generic public-key signature scheme and any secure hash function, modeled as a random oracle, to achieve strong anonymity, by using a unique construction reminiscent of onion routing. This allows Astrape to achieve provable security that's ``generic'' over the computational hardness assumptions of the underlying primitives. Astrape's simple cryptography also lends itself to more straightforward security proofs compared to existing systems.

Furthermore, we evaluate Astrape's performance, including that of a concrete implementation on the Bitcoin Cash blockchain. We show that despite worse theoretical time complexity compared to state-of-the-art systems that use custom cryptography, Astrape operations on average have a very competitive performance of less than 10 milliseconds of computation and 1\,KB of communication on commodity hardware. Astrape explores a new avenue to secure and anonymous PCNs that achieves similar or better performance compared to existing solutions.

## Guide to this repo

`astrape-extended.pdf` contains the extended version of the paper that will appear at [ACNS 2022](https://sites.google.com/di.uniroma1.it/acns2022/).

`bench/` contains the source code for the simulations and the Bitcoin Cash scripts. In particular:

- The `.rkt` files generate the plots. Run them with [Racket](https://racket-lang.org/), like `racket privover.rkt`, and they should spit out `.pdf` graphs in the same directory.
- The `test.cash` folder contains the Bitcoin Cash script, in CashScript format.
- `main.go` contains a Go simulator of Astrape. Adjust the argument passed to `setupAstrape`; that will adjust the number of hops simulated. The program should spit out how long 10000 runs of the Astrape simulation takes.
