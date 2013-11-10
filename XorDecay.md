
# XOR Decay and Fixed Points

**A plaintext injection attack against the 8 bit "stupid" cipher.**

The xor operation has a magical property - it preserves randomness.
If you take a known value and xor it with a random value, the result
is another random value.

This is the basis of many stream ciphers; a stream of independent,
uniformly distributed, random values is xored against the plaintext.
If the original random stream if "really" random, then the plaintext
will be too.

This gives the xor operation has a certain attractiveness - it seems
like the perfect building blog for constructing other cryptographic
functions.

Say you wanted to make your own stream cipher.  We've just seen how to
build one from a source of random numbers, but how do you construct
those numbers?  Xor seems like an obvious choice - start with some
intiial values (the key, perhaps) and xor them together.

TODO
