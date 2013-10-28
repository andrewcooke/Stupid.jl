
module Cipher
using Tasks2

export stupid, constant_text, encrypt, to_vector, tests


function stupid(key::Vector{Uint8}; debug=false, forwards=true)

    key = copy(key)  # don't mutate the passed key
    key_length = length(key)
    @assert key_length >= 3

    pos_a = key[1] % key_length
    pos_b = key[2] % key_length
    pos_c = key[3] % key_length
    count::Uint8 = 0

    function task(plain::Uint8)

        while true
            if debug
                @printf("%d %s %d %d %d\n", 
                        count, bytes2hex(key), pos_a, pos_b, pos_c)
            end
            old_a = pos_a
            pos_a = key[pos_b+1] % key_length
            pos_b = (pos_a + 1 + key[pos_c+1] % (key_length - 1)) % key_length
            pos_c = (pos_a + 1 + key[old_a+1] % (key_length - 1)) % key_length
            cipher::Uint8 = plain $ key[pos_a+1] $ key[pos_b+1]
            poison = forwards ? cipher : plain
            plain = produce2(cipher)
            key[pos_c+1] = (key[pos_c+1] << 31) | (key[pos_c+1] >> 1)
            key[pos_a+1] = key[pos_a+1] $ key[pos_c+1] $ count $ poison
            count = count + 1
        end

    end

    Task(task)
end

function constant_text(length, value::Uint8=zero(Uint8))
    
    function task()
        while length > 0
            produce2(value)
            length = length - 1
        end
    end

    Task(task)
end

function byte_text(text)

    function task()
        for c in text
            produce2(c)
        end
    end

    Task(task)
end

function encrypt(key, text; debug=false, forwards=true)
    
    s = stupid(key, debug=debug, forwards=forwards)

    function task()
        for c in text
            produce2(consume2(s, c))
        end
    end

    Task(task)
end
    
function to_vector(task)
    a = Array(Uint8, 0)
    for c in task
        push!(a, c)
    end
    a
end

function to_hex(task)
    bytes2hex(to_vector(task))
end


function test_vectors()

    # no test vectors are provided, so this is only an internal check
    # against bugs introduced later in the code

    three_zeroes = hex2bytes("000000")
    cipher = to_hex(encrypt(three_zeroes, constant_text(0x10)))
    @assert cipher == "00000102030405060708090a0b0c0d0e" cipher
    cipher = to_hex(encrypt(three_zeroes, constant_text(0x10, 0xff)))
    @assert cipher == "ff000102030405060708090a0b0c0d0e" cipher
    cipher = to_hex(encrypt(three_zeroes, constant_text(0x10, 0x55)))
    @assert cipher == "55000102030405060708090a0b0c0d0e" cipher
    cipher = to_hex(encrypt(three_zeroes, byte_text(b"secret")))
    @assert cipher == "731607131415" cipher

    eight_zeroes = hex2bytes("0000000000000000")
    cipher = to_hex(encrypt(eight_zeroes, constant_text(0x10)))
    @assert cipher == "00000102030405060708090a0b0c0d0e" cipher

    cipher = to_hex(encrypt(hex2bytes("010203"), constant_text(0x10)))
    @assert cipher == "02010202030404060708090a0b0c0d0e" cipher
    cipher = to_hex(encrypt(hex2bytes("010203"), byte_text(b"secret")))
    @assert cipher == "711704136263" cipher
end

function test_roundtrip()
    key = hex2bytes("010203")
    plain = to_vector(encrypt(key, 
                              encrypt(key, byte_text(b"secret")), 
                              forwards=false))
    @assert plain == b"secret" plain
end

function tests()
    test_vectors()
    test_roundtrip()
end

end
