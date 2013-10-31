
module Cipher
using Tasks2

export State, encrypt, to_hex, tests


type State
    key_length::Int
    key::Array{Uint8}  # mutated
    count::Uint8
    pos_a::Int
    pos_b::Int
    pos_c::Int

    function State(key::Array{Uint8})
        key_length = length(key)
        @assert key_length >= 3
        new(key_length, copy(key), 0x0, 
            key[1] % key_length, key[2] % key_length, key[3] % key_length)
    end
end

State(key::ASCIIString) = State(hex2bytes(key))

function Base.println(state::State)
    @printf("%4d %s %d/%02x %d/%02x %d/%02x\n", 
            state.count, bytes2hex(state.key), 
            state.pos_a, state.key[state.pos_a+1], 
            state.pos_b, state.key[state.pos_b+1], 
            state.pos_c, state.key[state.pos_c+1])
end

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

function encrypt(state::State; debug=false, forwards=true)
    Task() do plain
        while true
            cipher = encrypt(state, plain, debug=debug, forwards=forwards)
            plain = produce2(cipher)
        end
    end
end

function encrypt(state::State, plain::Task; debug=false, forwards=true)
    task = encrypt(state, debug=debug, forwards=forwards)
    Task() do 
        for c in plain
            produce2(consume2(task, c))
        end
    end
end


function to_hex(task::Task, n=-1)
    if n < 0
        bytes2hex(collect2(Uint8, task))
    else
        bytes2hex(collect2(Uint8, take(n, task)))
    end
end

end
