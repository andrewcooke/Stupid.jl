
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

# it turns out that the correlation is only useful for a few bits.


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
    cipher1 = encrypt(key1, plain)
    key2 = change_random_bits(key1)
    cipher2 = encrypt(key2, plain)
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
    draw(PNG("bitdistance-zero-3-4.png", 15cm, 10cm), 
         plot(distances(n, constant(0x0), 3, 4),
              x="key_distance", y="ciphertext_distance"))
    draw(PNG("bitdistance-count-3-4.png", 15cm, 10cm), 
         plot(distances(n, counter(), 3, 4),
              x="key_distance", y="ciphertext_distance"))
    draw(PNG("bitdistance-2bits-3-4.png", 15cm, 10cm), 
         plot(distances(n, choices([i for i=0x0:0x3]), 3, 4),
              x="key_distance", y="ciphertext_distance"))
    draw(PNG("bitdistance-4bit-3-4.png", 15cm, 10cm), 
         plot(distances(n, choices([i for i=0x0:0x7]), 3, 4),
              x="key_distance", y="ciphertext_distance"))
    draw(PNG("bitdistance-random-3-4.png", 15cm, 10cm), 
         plot(distances(n, rands(Uint8), 3, 4),
              x="key_distance", y="ciphertext_distance"))
    draw(PNG("bitdistance-count-3-128.png", 15cm, 10cm), 
         plot(distances(n, counter(), 3, 128),
              x="key_distance", y="ciphertext_distance"))
    draw(PNG("bitdistance-count-8-128.png", 15cm, 10cm), 
         plot(distances(n, counter(), 3, 128),
              x="key_distance", y="ciphertext_distance"))
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
#    plot_distances(100)
end

end
