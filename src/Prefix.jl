
module Prefix
using Cipher, Tasks2

export tests

# it seems that a counter plaintext can corrupt the state in some way
# (from experience with other approaches and buggy code). maybe we can
# then extract that state?  and then continue with plaintext which
# will be decryptable.

# first, see what the effect of the counter on state is by measuring
# the distance to stationary state with the counter plaintext.

function distance_to_stationary(key; debug=false)
    s = State(key)
    h0 = hash(s)
    h1 = h0 + 1
    c = counter()
    t = encrypt(s, c, debug=debug)
    while h0 != h1:
        consume(t)
        h0, h1 = h1, hash(s)
    end
    consume(c)
end


function test_distance()
    d = distance_to_stationary("010204", debug=true)
    @assert d == 42 d
    println("test_distance ok")
end

function tests()
    println("Prefix")
    test_distance()
end

end
