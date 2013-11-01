
module Cipher
using Tasks2, Rand2

export State, encrypt, to_hex, tests


type State
    # make persistent across calls so that we can examine and modify
    # at will
    key_length::Uint8
    key::Array{Uint8}  # mutated
    count::Uint8
    pos_a::Uint8
    pos_b::Uint8
    pos_c::Uint8

    function State(key::Array{Uint8})
        key_length = length(key)
        @assert key_length >= 3
        new(key_length, copy(key), 0x0, 
            key[1] % key_length, key[2] % key_length, key[3] % key_length)
    end
end

State(key::ASCIIString) = State(hex2bytes(key))
State(key::Task) = State(collect2(Uint8, key))

function small_hash(s)
    h::Int64 = s.key_length
    h = h << 8 | s.count
    h = h << 8 | s.pos_a
    h = h << 8 | s.pos_b
    h = h << 8 | s.pos_c
    for i = 1:s.key_length
        h = h << 8 | s.key[i]
    end
    h
end

function large_hash(s)
    h::Int64 = s.key_length
    h = h << 5 $ s.count
    h = h << 5 $ s.pos_a
    h = h << 5 $ s.pos_b
    h = h << 5 $ s.pos_c
    for i = 1:s.key_length
        h = (h << 5 | h >> 59) $ s.key[i]
    end
    h
end

Base.hash(s::State) = s.key_length > 4 ? large_hash(s) : small_hash(s)
Base.isequal(x::State, y::State) = (x.key_length == y.key_length &&
                                    x.count == y.count &&
                                    x.pos_a == y.pos_a &&
                                    x.pos_b == y.pos_b &&
                                    x.pos_c == y.pos_c &&
                                    x.key == y.key)

function Base.println(state::State)
    @printf("%4d %s %d/%02x %d/%02x %d/%02x\n", 
            state.count, bytes2hex(state.key), 
            state.pos_a, state.key[state.pos_a+1], 
            state.pos_b, state.key[state.pos_b+1], 
            state.pos_c, state.key[state.pos_c+1])
end


# single step evaluation

# this differs from http://news.quelsolaar.com/#comments101 in a
# couple of ways.

# first, it's all 8bit.  the original rotation was 32bit, which was
# also mentioned in the comments, yet that was used to modify a single
# input value.  since most stream ciphers work with 8bit "characters"
# it seemed more consistent (and makes my code more general for use
# with other ciphers) to stay with 8 bits.  this does reduce the
# amount of state available, which may be an issue.

# second, the original code has input labelled "encrypted" and output
# labelled "decrypted".  i think the logic below is equivalent (it
# would make no difference if it were a pure xor-based stream, but
# there's the additional wrinkle of the text being folded into the
# state).

function encrypt(state::State, plain::Uint8; debug=false, forwards=true)    
    if debug
        println(state)
    end

    old_a = state.pos_a
    state.pos_a = state.key[state.pos_b+1] % state.key_length
    state.pos_b = (state.pos_a + 1 + 
                   state.key[state.pos_c+1] % (state.key_length - 1)
                   ) % state.key_length
    state.pos_c = (state.pos_a + 1 + 
                   state.key[old_a+1] % (state.key_length - 1)
                   ) % state.key_length
    cipher::Uint8 = plain $ state.key[state.pos_a+1] $ state.key[state.pos_b+1]
    poison = forwards ? cipher : plain
    state.key[state.pos_c+1] = (state.key[state.pos_c+1] << 7 | 
                                state.key[state.pos_c+1] >> 1)
    state.key[state.pos_a+1] = (state.key[state.pos_a+1] $ 
                                state.key[state.pos_c+1] $ 
                                state.count $ poison)
    state.count = state.count + 1
    cipher
end

function encrypt(state::State, plain::Integer; debug=false, forwards=true)
    encrypt(state, convert(Uint8, plain), debug=debug, forwards=forwards)
end


# evaluation via coroutines (useful for evaluating streams of
# arbitrary length)

function encrypt(state::State; debug=false, forwards=true)
    Task() do plain
        while true
            cipher = encrypt(state, plain, debug=debug, forwards=forwards)
            plain = produce2(cipher)
        end
    end
end

function encrypt(key; debug=false, forwards=true)
    encrypt(State(key), debug=debug, forwards=forwards)
end

function encrypt(state::State, plain::Task; debug=false, forwards=true)
    task = encrypt(state, debug=debug, forwards=forwards)
    Task() do 
        for c in plain
            produce2(consume2(task, c))
        end
    end
end

function encrypt(key, plain::Task; debug=false, forwards=true)
    encrypt(State(key), plain, debug=debug, forwards=forwards)
end


# direct evaluation for known length text (more efficient)

function encrypt(state::State, plain::Array{Uint8}; debug=false, forwards=true)
    cipher = Array(Uint8, length(plain))
    for i = 1:length(plain)
        cipher[i] = encrypt(state, plain[i], debug=debug, forwards=forwards)
    end
    cipher
end

function encrypt(key, plain::Array{Uint8}; debug=false, forwards=true)
    encrypt(State(key), plain, debug=debug, forwards=forwards)
end


# utilities

function to_hex(task::Task, n=-1)
    if n < 0
        bytes2hex(collect2(Uint8, task))
    else
        bytes2hex(collect2(Uint8, take(n, task)))
    end
end

function to_hex(cipher::Array{Uint8})
    bytes2hex(cipher)
end

function random_key(key_length)
    collect2(Uint8, take(key_length, rands(Uint8)))
end


# tests

function random_examples(key_length, plain, label)
    @printf("random_examples begin [%d %s]\n", key_length, label)
    plain_length = div(80 - 2 * key_length - 2, 2)
    for i = 1:2
        key = random_key(key_length)
        cipher = to_hex(encrypt(key, plain), plain_length)
        @printf("%s: %s\n", to_hex(key), cipher)
    end
    println("random_examples end")
end

function test_state()
    state = State(hex2bytes("010203"))
    @assert state.key_length == 3
    @assert state.key == Uint8[0x1, 0x2, 0x3]
    @assert state.pos_a == 0x1
    @assert state.pos_b == 0x2
    @assert state.pos_c == 0x0  # wrapped
    @assert state.count == 0
    println("test_state ok")
end

function test_encrypt()
    state = State(hex2bytes("010203"))
    cipher = encrypt(state, 0x0, debug=true)
    @assert cipher == 0x2 cipher
    @assert state.count == 1

    task = encrypt(state, debug=true)
    cipher = consume2(task, 0x0)
    @assert cipher == 0x1 cipher
    @assert state.count == 2

    cipher = to_hex(encrypt(state, constant(0x0), debug=true), 2)
    @assert cipher == "0243" cipher
    @assert state.count == 4 state.count

    println("test_encrypt ok")
end

function test_vectors()

    # no test vectors are provided, so this is only an internal check
    # against bugs introduced later in the code

    cipher = to_hex(encrypt("000000", constant(0x0)), 0x10)
    @assert cipher == "00000102030405060708090a0b0c0d0e" cipher
    cipher = to_hex(encrypt("000000", constant(0xff)), 0x10)
    @assert cipher == "ff000102030405060708090a0b0c0d0e" cipher
    cipher = to_hex(encrypt("000000", iterate(b"secret")))
    @assert cipher == "731607131415" cipher
    cipher = to_hex(encrypt("000000", counter()), 0x10)
    @assert cipher == "000102030405060708090a0b0c0d0e0f" cipher

    eight_zeroes = hex2bytes("0000000000000000")
    cipher = to_hex(encrypt(eight_zeroes, constant(0x0)), 0x10)
    @assert cipher == "00000102030405060708090a0b0c0d0e" cipher

    cipher = to_hex(encrypt("010203", constant(0x0)), 0x10)
    @assert cipher == "0201024343c465873710c9066b0a3d16" cipher
    cipher = to_hex(encrypt("010203", b"secret"))
    @assert cipher == "71170492a494" cipher
    cipher = to_hex(encrypt("010203", counter()), 0x10)
    @assert cipher == "0200010284a4962fa835fac71d1c2cc3" cipher

    println("test_vectors ok")
end

function test_roundtrip()
    key = "010203"
    plain = collect2(Uint8, 
                     encrypt(key, encrypt(key, b"secret"), forwards=false))
    @assert plain == b"secret" plain
    println("test_roundtrip ok")
end

function tests()
    println("Cipher")
    test_state()
    test_encrypt()
    test_vectors()
    test_roundtrip()
    random_examples(3, constant(0x0), "zeroes")
    random_examples(8, constant(0x0), "zeroes")
    random_examples(3, counter(), "counter")
    random_examples(8, counter(), "counter")
    random_examples(3, rands(Uint8), "random")
    random_examples(8, rands(Uint8), "random")
end

end
