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

## Plaintext Injection Attack

In some cases, injecting a pre-calculated fragment in the plaintext
can force the internal state of the cipher to a known point (excluding
the internal counter, which is known anyway).  Following text can then
be decypted easily.

A practical example might be the encryption of a web page that
displays user-supplied data (like a name or comment).

The fragment is a counter (modulo 0xff) that mirrors the counter in
the cipher state.

For 3 byte keys, a 32 byte fragment affects 4% of keys.  For 4 byte
keys a longer fragment (120 bytes) is necessary to affect a similar
percentage.

Even when the known unique state is not achieved (including larger key
sizes), counter fragments *significantly* reduce the cipher state.  In
a random sample (size 100) of 8 byte keys encrypting a counter all had
state (excluding the internal counter) that repeated over unexpected
short periods.  The largest period was 319 an 43% achieved stationary
state (period 1) after 1500 characters or less.

The analysis can be seen in [Prefix.jl](src/Prefix.jl).
