
module BitDistance
using Cipher

# the output of any particlar byte in the cipher depends on only two
# bytes of the current state.  which means that early in the output it
# depends on only two bytes of the key.  and the dependeny is very
# simple (xor).

# so we expect the output for a fixed plaintext to change "smoothly"
# with changes to the key - that the bit distance between cipher texts
# should be small when the bit distance between keys is small.

# if that is correct then we can seach for the key by using the bit
# distance between the ciphertext for the key and the known
# ciphertext.

# below we:
# 1 - show this smoothness.
# 2 - estimate the amount of ciphertext needed to find all key bits.
# 3 - implement the search with genetic programming.

function random_distances(key_length=3)

    

end

end
