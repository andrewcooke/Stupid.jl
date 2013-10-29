# Stupid

Analysis of the "stupid" cipher at http://news.quelsolaar.com/#comments101

## Introduction

**Motivation** - it seems that the only way to learn about
implementing ciphers is to break them.  At the same time, the ciphers
that I know are ridiculously hard to break.  So breaking an "obviously
bad" design might be a good first step.

**Structure** - this page contains only a basic summary of the code
and results.  There are links to source files, which contain more
information in the comments.

**Language** - [Julia](http://julialang.org/) combines the speed of C
(or close) with the flexibility of Python and has ambitions to replace
statistical analysis packages like R.

## Attacks

### Known Plaintext, Bit Distance

For a given plaintext, changing a bit of the key changes only a small
amount of the initial ciphertext.  This allows a search for the key.

More information in the [BitDistance](./src/BitDistance.jl) module.
