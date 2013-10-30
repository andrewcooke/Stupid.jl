
module BitDistance
using Cipher, Tasks2, Gadfly, DataFrames, Rand2

export tests

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

function distance(ptext, key_length=3, plain_length=8)
    plain = collect2(Uint8, take(plain_length, ptext))
    key1 = collect2(Uint8, take(key_length, rands(Uint8)))
    cipher1 = collect2(Uint8, encrypt(key1, plain))
    key2 = change_random_bits(key1)
    cipher2 = collect2(Uint8, encrypt(key2, plain))

    bit_distance(key1, key2), bit_distance(cipher1, cipher2)
end

function distances(n, ptext, key_length=3, plain_length=8)
    pairs = take(n, repeat(() -> distance(ptext, key_length, plain_length)))
    data = collect(zip(pairs...))
    DataFrame(key_distance=[data[1]...], ciphertext_distance=[data[2]...])
end

function plot_distances(n)
    println("plot_distances begin")
    draw(PNG("bitdistance-count-3-4.png", 15cm, 10cm), 
         plot(distances(n, counter(), 3, 4),
              x="key_distance", y="ciphertext_distance"))
#    draw(PNG("bitdistance-random.png", 15cm, 10cm), 
#         plot(distances(n, rands(Uint8), key_length, plain_length),
#              x="key_distance", y="ciphertext_distance"))
    draw(PNG("bitdistance-zero-3-4.png", 15cm, 10cm), 
         plot(distances(n, constant(0x0), 3, 4),
              x="key_distance", y="ciphertext_distance"))
    draw(PNG("bitdistance-zero-3-8.png", 15cm, 10cm), 
         plot(distances(n, constant(0x0), 3, 8),
              x="key_distance", y="ciphertext_distance"))
    draw(PNG("bitdistance-zero-8-16.png", 15cm, 10cm), 
         plot(distances(n, constant(0x0), 8, 16),
              x="key_distance", y="ciphertext_distance"))
#    draw(PNG("bitdistance-4bit.png", 15cm, 10cm), 
#         plot(distances(n, choices([i for i=0x0:0x7]), 
#                        key_length, plain_length),
#              x="key_distance", y="ciphertext_distance"))
    println("plot_distances end")
end


function test_distance()
    d = bit_distance(hex2bytes("10001f"), hex2bytes("300005"))
    @assert d == 4
    println("test_distance ok")
end

function tests()
    println("BitDistance")
    test_distance()
    plot_distances(100)
end

end
