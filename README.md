# Stupid

Analysis of an 8-bit version of the "stupid" cipher at
http://news.quelsolaar.com/#comments101

## Introduction

**Motivation** - it seems that the only way to learn about
implementing ciphers is to break them.  At the same time, the ciphers
that I know are ridiculously hard to break.  So breaking a "known bad"
design might be a good first step.

**Structure** - this page contains only a basic summary of the code
and results.  There are links to source files, which contain more
information in the comments.

**Language** - [Julia](http://julialang.org/) combines the speed of C
(or close) with the flexibility of Python and has ambitions to replace
statistical analysis packages like R.

## Results

So far the only strong result I have is that a chosen plaintext can
erase the PRNG state.  See the comments in
[BitDistance.jl](src/BitDistance.jl) for more details.

While this illustrates the weakness of the PRNG construction, it does
not lead to an attack, since the key data are not exposed.
