
module Cipher
using Tasks2

export stupid, constant_text, byte_text, encrypt, to_vector, to_hex, tests


function stupid(key::Vector{Uint8}; debug=false, forwards=true)

    # this is a generator so that we can do pipelined analysis without
    # creating large intermediate files (and i found it generally useful
    # to use generators while working on the crypto challenge in python,
    # so wanted to explore the same ideas here).

    key = copy(key)  # don't mutate the passed key
    key_length = length(key)
    @assert key_length >= 3

    pos_a = key[1] % key_length
    pos_b = key[2] % key_length
    pos_c = key[3] % key_length
    count::Uint8 = 0

    function task(plain::Uint8)

        # the original isn't clear on the size of the keys (in fact,
        # it mentions 32bits at one point).  here i've gone with what
        # seems more normal - encrypting a stream of bytes with keys
        # in bytes.

        # the original had the encrypted text named as "decrypted" and
        # vice versa.  i don't know if that was a language mistake, or
        # something deeper.  it may mean that the "poison" is
        # incorrect below.

        # it's unclear to me why (key_length - 1) is used, but that's
        # verbatim.

        # julia uses 1-based indexing, hence the "pos_X+1" eveywhere.
        # i think that keeps the semantics equivalent (no test
        # vectors).

        while true
            if debug
                @printf("%4d %s %d/%02x %d/%02x %d/%02x\n", 
                        count, bytes2hex(key), pos_a, key[pos_a+1], 
                        pos_b, key[pos_b+1], pos_c, key[pos_c+1])
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

function counter(length; start=0)

    function task()
        for i = 1:length
            produce2(uint8(i - 1 + start))
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
    cipher = to_hex(encrypt(three_zeroes, counter(8))) # state here always zero
    @assert cipher == "0001020304050607" cipher

    eight_zeroes = hex2bytes("0000000000000000")
    cipher = to_hex(encrypt(eight_zeroes, constant_text(0x10)))
    @assert cipher == "00000102030405060708090a0b0c0d0e" cipher

    one_two_three = hex2bytes("010203")
    cipher = to_hex(encrypt(one_two_three, constant_text(0x10)))
    @assert cipher == "02010202030404060708090a0b0c0d0e" cipher
    cipher = to_hex(encrypt(one_two_three, byte_text(b"secret")))
    @assert cipher == "711704136263" cipher
    cipher = to_hex(encrypt(one_two_three, counter(8)))
    @assert cipher == "0200010305050607" cipher
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
