
module BitDistance
using Cipher, Tasks2, Gadfly, DataFrames, Rand2

export tests

# the output of any particlar byte in the cipher depends on only two
# bytes of the current state.  which means that early in the output it
# depends on only two bytes of the key.  and the dependeny is very
# simple (xor).

# so it seems like channge the key by a small amount may only change
# the ciphertext by a small amount, at least early in the message.

# to test this, we encrypt text with a random key, modify the key,
# encrypt again, and then plot the bit distance between keys with the
# bit distance between ciphertexts.

# it turns out that there is little correlation (except for the first
# key bit in certain cases).

# however, when the message is a counter (which xors against the
# counter in the prng core) the bit distance between ciphertexts is
# curiously bimodal.

# inspecting the ciphertexts in these cases, they appear like
# fa3178ac9713e650: 61ad7394d10f770d9287eceba64c2c313f02192d121d080e12
# 05132414172b202f29222d242023252a2b2a2f2d2c2f2c303132333435363738393a
# 3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c
# 5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f

# inspecting the state, it has dropped to zero in most bytes, with
# constant pointers:

#   0 fa3178ac9713e650 2/78 1/31 0/fa
#   1 fa0678569713e650 1/06 7/50 3/56
#   2 7e0678569713e628 0/7e 3/56 7/28
#   3 7e06785697138314 6/83 4/97 7/14
#   4 7e0678569709838a 7/8a 6/83 5/09
#   5 7e0378809709838a 3/80 6/83 1/03
#   6 7e0378cb9709418a 3/cb 7/8a 6/41
#   7 7e036c659709418a 2/6c 5/09 3/65
#   8 7e0d6c659704418a 1/0d 5/04 5/04
#   9 7e0d6c323f04418a 4/3f 1/0d 3/32
#  10 7e0d6c323faa208a 5/aa 7/8a 6/20
#  11 7e0ddf323f55208a 2/df 7/8a 5/55
#  12 7e0639323f55208a 2/39 4/3f 1/06
#  13 7e0339323f552023 7/23 6/20 1/03
#  14 3e0139323f552023 0/3e 4/3f 1/01
#  15 3e0139323f551011 7/11 1/01 6/10
#  16 3e1539323f2a1011 1/15 4/3f 5/2a
#  17 1f1539323f2a1021 7/21 0/1f 0/1f
#  18 1f1539323f151027 7/27 3/32 5/15
#  19 1f1521323f151013 2/21 3/32 7/13
#  20 0f1510323f151013 2/10 0/0f 0/0f
#  21 0f1508323f15101d 7/1d 1/15 2/08
#  22 0f1508323f13100e 5/13 7/0e 7/0e
#  23 0f1508321f13110e 6/11 7/0e 4/1f
#  24 0f1504321f130c0e 6/0c 2/04 2/04
#  25 0f15023217130c0e 4/17 1/15 2/02
#  26 0715023217080c0e 5/08 0/07 0/07
#  27 070a023217080c0d 7/0d 0/07 1/0a
#  28 070a023217080634 7/34 3/32 6/06
#  29 070a093217080334 2/09 1/0a 6/03
#  30 070a073217040334 2/07 6/03 5/04
#  31 070a070c0b040334 3/0c 0/07 4/0b
#  32 070a070c0b020309 7/09 4/0b 5/02
#  33 070a07020b020109 3/02 6/01 6/01
#  34 0707070205020109 1/07 3/02 4/05
#  35 0707060105020109 2/06 0/07 3/01
#  36 0707060105020007 7/07 1/07 6/00
#  37 0307060105020004 7/04 0/03 0/03
#  38 0107060505020004 3/05 7/04 0/01
#  39 0107030503020004 4/03 6/00 2/03
#  40 0207030501020004 0/02 4/01 4/01
#  41 0205030500020004 1/05 3/05 4/00
#  42 0205030200020004 5/02 6/00 3/02
#  43 0305030100020004 0/03 3/01 3/01
#  44 0300030100010004 1/00 3/01 5/01
#  45 0300010100010004 1/00 3/01 2/01
#  46 0301000100010004 1/01 3/01 2/00
#  47 0300000000010004 1/00 2/00 3/00
#  48 0000000000010004 0/00 1/00 1/00
#  49 0000000000010004 0/00 1/00 1/00

# which appears to happen when pos_a == pos_c (the contents are then
# xored, giving zero).


function count_bits(n::Uint8)
    mask = 1
    count = 0
    for i = 1:8
        if n & mask != 0
            count = count + 1
        end
        mask = mask << 1
    end
    count
end

BITS = Uint[count_bits(n) for n = typemin(Uint8):typemax(Uint8)]

function bit_distance(a::Array{Uint8}, b::Array{Uint8})
    distance = 0
    for (aa, bb) in zip(a, b)
        distance = distance + BITS[(aa $ bb) + 1]
    end
    return distance
end

function flip_bit(bit, bytes)  # bit is zero-indexed
    a = Array(Uint8, 0)
    for byte in bytes
        if bit >= 0 && bit < 8
            push!(a, byte $ (0x1 << bit))
        else
            push!(a, byte)
        end
        bit = bit - 8
    end
    a
end

function change_random_bits(bytes)
    b = 8 * length(bytes)
    bits = Int[i for i=0:b-1]
    for i = 1:rand(0:b)
        bit = choice(bits)
        filter!(b -> b != bit, bits)
        bytes = flip_bit(bit, bytes)
    end
    bytes
end

function distance(ptext, key_length=3, plain_length=8; debug=false)
    plain = collect2(Uint8, take(plain_length, ptext))
    key1 = collect2(Uint8, take(key_length, rands(Uint8)))
    cipher1 = collect2(Uint8, encrypt(key1, plain))
    key2 = change_random_bits(key1)
    cipher2 = collect2(Uint8, encrypt(key2, plain))
    key_distance = bit_distance(key1, key2)
    ciphertext_distance = bit_distance(cipher1, cipher2)
    if debug
        @printf("%s: %s  %s: %s  %2d %2d\n", 
                bytes2hex(key1), bytes2hex(cipher1),
                bytes2hex(key2), bytes2hex(cipher2),
                key_distance, ciphertext_distance)
        end
    key_distance, ciphertext_distance
end

function distances(n, ptext, key_length=3, plain_length=8; debug=false)
    pairs = take(n, repeat(() -> distance(ptext, key_length, plain_length, 
                                          debug=debug)))
    data = collect(zip(pairs...))
    DataFrame(key_distance=[data[1]...], ciphertext_distance=[data[2]...])
end

function plot_distances(n)
    println("plot_distances begin")
#    draw(PNG("bitdistance-count-3-4.png", 15cm, 10cm), 
#         plot(distances(n, counter(), 3, 4, debug=true),
#              x="key_distance", y="ciphertext_distance"))
    draw(PNG("bitdistance-count-8-128.png", 15cm, 10cm), 
         plot(distances(n, counter(), 8, 128, debug=true),
              x="key_distance", y="ciphertext_distance"))
#    draw(PNG("bitdistance-zero-8-128.png", 15cm, 10cm), 
#         plot(distances(n, constant(0x0), 8, 128, debug=true),
#              x="key_distance", y="ciphertext_distance"))
#    draw(PNG("bitdistance-2bits-8-128.png", 15cm, 10cm), 
#         plot(distances(n, choices([i for i=0x0:0x3]), 8, 128, debug=true),
#              x="key_distance", y="ciphertext_distance"))
#    draw(PNG("bitdistance-random-8-128.png", 15cm, 10cm), 
#         plot(distances(n, rands(Uint8), 8, 128, debug=true),
#              x="key_distance", y="ciphertext_distance"))
#    draw(PNG("bitdistance-random.png", 15cm, 10cm), 
#         plot(distances(n, rands(Uint8), key_length, plain_length),
#              x="key_distance", y="ciphertext_distance"))
#    draw(PNG("bitdistance-zero-3-4.png", 15cm, 10cm), 
#         plot(distances(n, constant(0x0), 3, 4),
#              x="key_distance", y="ciphertext_distance"))
#    draw(PNG("bitdistance-zero-3-8.png", 15cm, 10cm), 
#         plot(distances(n, constant(0x0), 3, 8),
#              x="key_distance", y="ciphertext_distance"))
#    draw(PNG("bitdistance-zero-8-16.png", 15cm, 10cm), 
#         plot(distances(n, constant(0x0), 8, 16),
#              x="key_distance", y="ciphertext_distance"))
#    draw(PNG("bitdistance-4bit.png", 15cm, 10cm), 
#         plot(distances(n, choices([i for i=0x0:0x7]), 
#                        key_length, plain_length),
#              x="key_distance", y="ciphertext_distance"))
    println("plot_distances end")
end

function examine_state()
    println("examine_state begin")
    collect(take(128, encrypt(hex2bytes("fa3178ac9713e650"), counter(0x0), 
                              debug=true)))
    println("examine_state end")
end

function test_distance()
    d = bit_distance(hex2bytes("10001f"), hex2bytes("300005"))
    @assert d == 4
    println("test_distance ok")
end

function tests()
    println("BitDistance")
    test_distance()
#    plot_distances(100)
    examine_state()
end

end
