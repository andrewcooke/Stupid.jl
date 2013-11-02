
module BitDistance
using Cipher, Tasks2, Rand2

export bit_distance, change_random_bits, BITS


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

const BITS = Uint8[count_bits(n) for n = typemin(Uint8):typemax(Uint8)]

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
    # this does selection without replacement (so no bit is changed
    # more than once)
    b = 8 * length(bytes)
    bits = Int[i for i=0:b-1]
    for i = 1:rand(0:b)
        bit = choice(bits)
        filter!(b -> b != bit, bits)
        bytes = flip_bit(bit, bytes)
    end
    bytes
end


function test_distance()
    d = bit_distance(hex2bytes("10001f"), hex2bytes("300005"))
    @assert d == 4
    println("test_distance ok")
end

function tests()
    println("BitDistance")
    test_distance()
end

end
