
module BruteForce
using Cipher, Tasks2, Rand2

export tests


# if we have the plain and cipher text for a character then we can fix
# state.key[state.pos_a+1] $ state.key[state.pos_b+1] and so find 8
# bits of internal state.

# here i've hand-unrolled the first loop.  it's not clear to me if
# this could be automated or extended to further loops.  but it does
# seem like it would easy to extend to larger keys.


function force3(oracle, plain, cipher)
    Task() do
        for key1_mod_3 = 0:2  # initial pos_b

            if key1_mod_3 == 0  # initial pos_b == 0

                for key0_mod_3 = 0:2  # key[pos_b] % key_length
                    pos_a = key0_mod_3  # updated pos_a (same as initial pos_a)
                    for key2_mod_3 = 0:2  # initial pos_c
                        
                        if key2_mod_3 == 0  # initial pos_c == 0
                            for key0_mod_2 = 0:1  # key[pos_c] % (key_length - 1)
                                pos_b = (pos_a + 1 + key0_mod_2) % 3  # updated pos_b
                                if pos_a == 0
                                    for key0 = 0:255  # key[pos_a]
                                        if key0 % 2 == key0_mod_2 && key0 % 3 == key0_mod_3
                                            if pos_b == 0
                                                @assert false  # cannot happen - pos_a != pos_b
                                            elseif pos_b == 1
                                                key1 = cipher[1] $ plain[1] $ key0  # infer key[pos_b]
                                                if key1 % 3 == key1_mod_3
                                                    for key2 = 0:255
                                                        if key2 % 3 == key2_mod_3
                                                            key = Uint8[key0, key1, key2]
                                                            if oracle(key)
                                                                produce(key)
                                                            end
                                                        end
                                                    end
                                                end
                                            elseif pos_b == 2
                                                key2 = cipher[1] $ plain[1] $ key0  # infer key[pos_b]
                                                if key2 % 3 == key2_mod_3
                                                    for key1 = 0:255
                                                        if key1 % 3 == key1_mod_3
                                                            key = Uint8[key0, key1, key2]
                                                            if oracle(key)
                                                                produce(key)
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                elseif pos_a == 1
                                    for key1 = 0:255  # key[pos_a]
                                        if key1 % 3 == key1_mod_3
                                            if pos_b == 0
                                                key0 = cipher[1] $ plain[1] $ key1  # infer key[pos_b]
                                                if key0 % 2 == key0_mod_2 && key0 % 3 == key0_mod_3
                                                    for key2 = 0:255
                                                        if key2 % 3 == key2_mod_3
                                                            key = Uint8[key0, key1, key2]
                                                            if oracle(key)
                                                                produce(key)
                                                            end
                                                        end
                                                    end
                                                end
                                            elseif pos_b == 1
                                                @assert false  # cannot happen - pos_a != pos_b
                                            elseif pos_b == 2
                                                key2 = cipher[1] $ plain[1] $ key1  # infer key[pos_b]
                                                if key2 % 3 == key2_mod_3
                                                    for key0 = 0:255
                                                        if key0 % 2 == key0_mod_2 && key0 % 3 == key0_mod_3
                                                            key = Uint8[key0, key1, key2]
                                                            if oracle(key)
                                                                produce(key)
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                elseif pos_a == 2
                                    for key2 = 0:255  # key[pos_a]
                                        if key2 % 3 == key2_mod_3
                                            if pos_b == 0
                                                key0 = cipher[1] $ plain[1] $ key2  # infer key[pos_b]
                                                if key0 % 2 == key0_mod_2 && key0 % 3 == key0_mod_3
                                                    for key1 = 0:255
                                                        if key1 % 3 == key1_mod_3
                                                            key = Uint8[key0, key1, key2]
                                                            if oracle(key)
                                                                produce(key)
                                                            end
                                                        end
                                                    end
                                                end
                                            elseif pos_b == 1
                                                key1 = cipher[1] $ plain[1] $ key2  # infer key[pos_b]
                                                if key1 % 3 == key1_mod_3
                                                    for key0 = 0:255
                                                        if key0 % 2 == key0_mod_2 && key0 % 3 == key0_mod_3
                                                            key = Uint8[key0, key1, key2]
                                                            if oracle(key)
                                                                produce(key)
                                                            end
                                                        end
                                                    end
                                                end
                                            elseif pos_b == 2
                                                @assert false  # cannot happen - pos_a != pos_b
                                            end
                                        end
                                    end
                                end  
                            end # end of pos_a alternatives for initial pos_b = 0, initial pos_c == 0

                        elseif key2_mod_3 == 1  # initial pos_c == 1
                            for key1_mod_2 = 0:1  # key[pos_c] % (key_length - 1)
                                pos_b = (pos_a + 1 + key1_mod_2) % 3  # updated pos_b
                                if pos_a == 0
                                    for key0 = 0:255  # key[pos_a]
                                        if key0 % 3 == key0_mod_3
                                            if pos_b == 0
                                                @assert false  # cannot happen - pos_a != pos_b
                                            elseif pos_b == 1
                                                key1 = cipher[1] $ plain[1] $ key0  # infer key[pos_b]
                                                if key1 % 2 == key1_mod_2 && key1 % 3 == key1_mod_3
                                                    for key2 = 0:255
                                                        if key2 % 3 == key2_mod_3
                                                            key = Uint8[key0, key1, key2]
                                                            if oracle(key)
                                                                produce(key)
                                                            end
                                                        end
                                                    end
                                                end
                                            elseif pos_b == 2
                                                key2 = cipher[1] $ plain[1] $ key0  # infer key[pos_b]
                                                if key2 % 3 == key2_mod_3
                                                    for key1 = 0:255
                                                        if key1 % 2 == key1_mod_2 && key1 % 3 == key1_mod_3
                                                            key = Uint8[key0, key1, key2]
                                                            if oracle(key)
                                                                produce(key)
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                elseif pos_a == 1
                                    for key1 = 0:255  # key[pos_a]
                                        if key1 % 2 == key1_mod_2 && key1 % 3 == key1_mod_3
                                            if pos_b == 0
                                                key0 = cipher[1] $ plain[1] $ key1  # infer key[pos_b]
                                                if key0 % 3 == key0_mod_3
                                                    for key2 = 0:255
                                                        if key2 % 3 == key2_mod_3
                                                            key = Uint8[key0, key1, key2]
                                                            if oracle(key)
                                                                produce(key)
                                                            end
                                                        end
                                                    end
                                                end
                                            elseif pos_b == 1
                                                @assert false  # cannot happen - pos_a != pos_b
                                            elseif pos_b == 2
                                                key2 = cipher[1] $ plain[1] $ key1  # infer key[pos_b]
                                                if key2 % 3 == key2_mod_3
                                                    for key0 = 0:255
                                                        if key0 % 3 == key0_mod_3
                                                            key = Uint8[key0, key1, key2]
                                                            if oracle(key)
                                                                produce(key)
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                elseif pos_a == 2
                                    for key2 = 0:255  # key[pos_a]
                                        if key2 % 3 == key2_mod_3
                                            if pos_b == 0
                                                key0 = cipher[1] $ plain[1] $ key2  # infer key[pos_b]
                                                if key0 % 3 == key0_mod_3
                                                    for key1 = 0:255
                                                        if key1 % 2 == key1_mod_2 && key1 % 3 == key1_mod_3
                                                            key = Uint8[key0, key1, key2]
                                                            if oracle(key)
                                                                produce(key)
                                                            end
                                                        end
                                                    end
                                                end
                                            elseif pos_b == 1
                                                key1 = cipher[1] $ plain[1] $ key2  # infer key[pos_b]
                                                if key1 % 2 == key1_mod_2 && key1 % 3 == key1_mod_3
                                                    for key0 = 0:255
                                                        if key0 % 3 == key0_mod_3
                                                            key = Uint8[key0, key1, key2]
                                                            if oracle(key)
                                                                produce(key)
                                                            end
                                                        end
                                                    end
                                                end
                                            elseif pos_b == 2
                                                @assert false  # cannot happen - pos_a != pos_b
                                            end
                                        end
                                    end
                                end 
                            end # end of pos_a alternatives for initial pos_b = 0, initial pos_c == 1

                        elseif key2_mod_3 == 2  # initial pos_c == 2
                            for key2_mod_2 = 0:1  # key[pos_c] % (key_length - 1)
                                pos_b = (pos_a + 1 + key2_mod_2) % 3  # updated pos_b
                                if pos_a == 0
                                    for key0 = 0:255  # key[pos_a]
                                        if key0 % 3 == key0_mod_3
                                            if pos_b == 0
                                                @assert false  # cannot happen - pos_a != pos_b
                                            elseif pos_b == 1
                                                key1 = cipher[1] $ plain[1] $ key0  # infer key[pos_b]
                                                if key1 % 3 == key1_mod_3
                                                    for key2 = 0:255
                                                        if key2 % 2 == key2_mod_2 && key2 % 3 == key2_mod_3
                                                            key = Uint8[key0, key1, key2]
                                                            if oracle(key)
                                                                produce(key)
                                                            end
                                                        end
                                                    end
                                                end
                                            elseif pos_b == 2
                                                key2 = cipher[1] $ plain[1] $ key0  # infer key[pos_b]
                                                if key2 % 2 == key2_mod_2 && key2 % 3 == key2_mod_3
                                                    for key1 = 0:255
                                                        if key1 % 3 == key1_mod_3
                                                            key = Uint8[key0, key1, key2]
                                                            if oracle(key)
                                                                produce(key)
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                elseif pos_a == 1
                                    for key1 = 0:255  # key[pos_a]
                                        if key1 % 3 == key1_mod_3
                                            if pos_b == 0
                                                key0 = cipher[1] $ plain[1] $ key1  # infer key[pos_b]
                                                if key0 % 3 == key0_mod_3
                                                    for key2 = 0:255
                                                        if key2 % 2 == key2_mod_2 && key2 % 3 == key2_mod_3
                                                            key = Uint8[key0, key1, key2]
                                                            if oracle(key)
                                                                produce(key)
                                                            end
                                                        end
                                                    end
                                                end
                                            elseif pos_b == 1
                                                @assert false  # cannot happen - pos_a != pos_b
                                            elseif pos_b == 2
                                                key2 = cipher[1] $ plain[1] $ key1  # infer key[pos_b]
                                                if key2 % 2 == key2_mod_2 && key2 % 3 == key2_mod_3
                                                    for key0 = 0:255
                                                        if key0 % 3 == key0_mod_3
                                                            key = Uint8[key0, key1, key2]
                                                            if oracle(key)
                                                                produce(key)
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                elseif pos_a == 2
                                    for key2 = 0:255  # key[pos_a]
                                        if key2 % 2 == key2_mod_2 && key2 % 3 == key2_mod_3
                                            if pos_b == 0
                                                key0 = cipher[1] $ plain[1] $ key2  # infer key[pos_b]
                                                if key0 % 3 == key0_mod_3
                                                    for key1 = 0:255
                                                        if key1 % 3 == key1_mod_3
                                                            key = Uint8[key0, key1, key2]
                                                            if oracle(key)
                                                                produce(key)
                                                            end
                                                        end
                                                    end
                                                end
                                            elseif pos_b == 1
                                                key1 = cipher[1] $ plain[1] $ key2  # infer key[pos_b]
                                                if key1 % 3 == key1_mod_3
                                                    for key0 = 0:255
                                                        if key0 % 3 == key0_mod_3
                                                            key = Uint8[key0, key1, key2]
                                                            if oracle(key)
                                                                produce(key)
                                                            end
                                                        end
                                                    end
                                                end
                                            elseif pos_b == 2
                                                @assert false  # cannot happen - pos_a != pos_b
                                            end
                                        end
                                    end
                                end  
                            end 
                        end  # end of pos_a alternatives for initial pos_b = 0, initial pos_c == 2
                    end
                end  

            elseif key1_mod_3 == 1  # initial pos_b == 1

                pos_a = 1  # updated pos_a (equal to initial pos_b)

                for key2_mod_3 = 0:2  # initial pos_c
                        
                    if key2_mod_3 == 0  # initial pos_c == 0
                        for key0_mod_2 = 0:1  # key[pos_c] % (key_length - 1)
                            pos_b = (pos_a + 1 + key0_mod_2) % 3  # updated pos_b
                            for key1 = 0:255  # key[pos_a]
                                if key1 % 3 == key1_mod_3
                                    if pos_b == 0
                                        key0 = cipher[1] $ plain[1] $ key1  # infer key[pos_b]
                                        if key0 % 2 == key0_mod_2
                                            for key2 = 0:255
                                                if key2 % 3 == key2_mod_3
                                                    key = Uint8[key0, key1, key2]
                                                    if oracle(key)
                                                        produce(key)
                                                    end
                                                end
                                            end
                                        end
                                    elseif pos_b == 1
                                        @assert false  # cannot happen - pos_a != pos_b
                                    elseif pos_b == 2
                                        key2 = cipher[1] $ plain[1] $ key1  # infer key[pos_b]
                                        if key2 % 3 == key2_mod_3
                                            for key0 = 0:255
                                                if key0 % 2 == key0_mod_2
                                                    key = Uint8[key0, key1, key2]
                                                    if oracle(key)
                                                        produce(key)
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end

                    elseif key2_mod_3 == 1  # initial pos_c == 1
                        for key1_mod_2 = 0:1  # key[pos_c] % (key_length - 1)
                            pos_b = (pos_a + 1 + key1_mod_2) % 3  # updated pos_b
                            for key1 = 0:255  # key[pos_a]
                                if key1 % 2 == key1_mod_2 && key1 % 3 == key1_mod_3
                                    if pos_b == 0
                                        key0 = cipher[1] $ plain[1] $ key1  # infer key[pos_b]
                                        for key2 = 0:255
                                            if key2 % 3 == key2_mod_3
                                                key = Uint8[key0, key1, key2]
                                                if oracle(key)
                                                    produce(key)
                                                end
                                            end
                                        end
                                    elseif pos_b == 1
                                        @assert false  # cannot happen - pos_a != pos_b
                                    elseif pos_b == 2
                                        key2 = cipher[1] $ plain[1] $ key1  # infer key[pos_b]
                                        if key2 % 3 == key2_mod_3
                                            for key0 = 0:255
                                                key = Uint8[key0, key1, key2]
                                                if oracle(key)
                                                    produce(key)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end

                    elseif key2_mod_3 == 2  # initial pos_c == 2
                        for key2_mod_2 = 0:1  # key[pos_c] % (key_length - 1)
                            pos_b = (pos_a + 1 + key2_mod_2) % 3  # updated pos_b
                            for key1 = 0:255  # key[pos_a]
                                if key1 % 3 == key1_mod_3
                                    if pos_b == 0
                                        key0 = cipher[1] $ plain[1] $ key1  # infer key[pos_b]
                                        for key2 = 0:255
                                            if key2 % 2 == key2_mod_2 && key2 % 3 == key2_mod_3
                                                key = Uint8[key0, key1, key2]
                                                if oracle(key)
                                                    produce(key)
                                                end
                                            end
                                        end
                                    elseif pos_b == 1
                                        @assert false  # cannot happen - pos_a != pos_b
                                    elseif pos_b == 2
                                        key2 = cipher[1] $ plain[1] $ key1  # infer key[pos_b]
                                        if key2 % 2 == key2_mod_2 && key2 % 3 == key2_mod_3
                                            for key0 = 0:255
                                                key = Uint8[key0, key1, key2]
                                                if oracle(key)
                                                    produce(key)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end

            elseif key1_mod_3 == 2  # initial pos_b == 2

                for key2_mod_3 = 0:2  # key[pos_b] % key_length

                    pos_a = key2_mod_3  # updated pos_a
                        
                    if key2_mod_3 == 0  # initial pos_c == 0 (and pos_a)
                        for key0_mod_2 = 0:1  # key[pos_c] % (key_length - 1)
                            pos_b = (pos_a + 1 + key0_mod_2) % 3  # updated pos_b
                            for key0 = 0:255  # key[pos_a]
                                if key0 % 2 == key0_mod_2
                                    if pos_b == 0
                                        @assert false  # cannot happen - pos_a != pos_b
                                    elseif pos_b == 1
                                        key1 = cipher[1] $ plain[1] $ key0  # infer key[pos_b]
                                        if key1 % 3 == key1_mod_3
                                            for key2 = 0:255
                                                if key2 % 3 == key2_mod_3
                                                    key = Uint8[key0, key1, key2]
                                                    if oracle(key)
                                                        produce(key)
                                                    end
                                                end
                                            end
                                        end
                                    elseif pos_b == 2
                                        key2 = cipher[1] $ plain[1] $ key0  # infer key[pos_b]
                                        if key2 % 3 == key2_mod_3
                                            for key1 = 0:255
                                                if key1 % 3 == key1_mod_3
                                                    key = Uint8[key0, key1, key2]
                                                    if oracle(key)
                                                        produce(key)
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end  # end of initial pos_c == 0

                    elseif key2_mod_3 == 1  # initial pos_c == 1 (and pos_a)
                        for key1_mod_2 = 0:1  # key[pos_c] % (key_length - 1)
                            pos_b = (pos_a + 1 + key1_mod_2) % 3  # updated pos_b
                            for key1 = 0:255  # key[pos_a]
                                if key1 % 2 == key1_mod_2 && key1 % 3 == key1_mod_3
                                    if pos_b == 0
                                        key0 = cipher[1] $ plain[1] $ key1  # infer key[pos_b]
                                        for key2 = 0:255
                                            if key2 % 3 == key2_mod_3
                                                key = Uint8[key0, key1, key2]
                                                if oracle(key)
                                                    produce(key)
                                                end
                                            end
                                        end
                                    elseif pos_b == 1
                                        @assert false  # cannot happen - pos_a != pos_b
                                    elseif pos_b == 2
                                        key2 = cipher[1] $ plain[1] $ key1  # infer key[pos_b]
                                        if key2 % 3 == key2_mod_3
                                            for key0 = 0:255
                                                key = Uint8[key0, key1, key2]
                                                if oracle(key)
                                                    produce(key)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end  # end of initial pos_c == 1

                    elseif key2_mod_3 == 2  # initial pos_c == 2 (and pos_a)
                        for key2_mod_2 = 0:1  # key[pos_c] % (key_length - 1)
                            pos_b = (pos_a + 1 + key2_mod_2) % 3  # updated pos_b
                            for key2 = 0:255  # key[pos_a]
                                if key2 % 2 == key2_mod_2 && key2 % 3 == key2_mod_3
                                    if pos_b == 0
                                        key0 = cipher[1] $ plain[1] $ key2  # infer key[pos_b]
                                        for key1 = 0:255
                                            if key1 % 3 == key1_mod_3
                                                key = Uint8[key0, key1, key2]
                                                if oracle(key)
                                                    produce(key)
                                                end
                                            end
                                        end
                                    elseif pos_b == 1
                                        key1 = cipher[1] $ plain[1] $ key2  # infer key[pos_b]
                                        if key1 % 3 == key1_mod_3
                                            for key0 = 0:255
                                                key = Uint8[key0, key1, key2]
                                                if oracle(key)
                                                    produce(key)
                                                end
                                            end
                                        end
                                    elseif pos_b == 2
                                        @assert false  # cannot happen - pos_a != pos_b
                                    end
                                end
                            end
                        end  # end of initial pos_c == 2
                    end
                end  
            
            end  # end of pos_b choices

        end  # pos_b loop
    end  # task
end  # function


function exact_oracle(key)
    function oracle(k)
        k == key
    end
end

function test_exact()
    for key0 = 0:255
        for key1 = 0:255
            println(to_hex(Uint8[key0, key1]))
            for key2 = 0:255
                key = Uint8[key0, key1, key2]
                cipher = encrypt(key, Uint8[0x0])
                oracle = exact_oracle(key)
                keys = collect(force3(oracle, plain, cipher))
                if length(keys) != 1
                    @printf("%s: %d\n", to_hex(key), length(keys))
                end
            end
        end
    end
end

function test_exact_random(n)
    @printf("test_exact_random begin [%d]\n", n)
    for i = 1:n
        if i % 100 == 0
            println(i)
        end
        key = collect2(Uint8, take(3, rands(Uint8)))
        plain = Uint8[rand(Uint8)]
        cipher = encrypt(key, plain)
        oracle = exact_oracle(key)
        keys = collect(force3(oracle, plain, cipher))
        if length(keys) != 1
            @printf("%s: %s/%s %d\n", to_hex(key), to_hex(plain), to_hex(cipher), length(keys))
        end
    end
    println("test_exact_random end")
end


function plain_oracle(cipher, plain)
    function oracle(k)
        p = encrypt(k, cipher, forwards=false)
#        @printf("%s: %s %s %d\n", to_hex(k), to_hex(p), to_hex(plain), p == plain ? 1 : 0)
        return p == plain
    end
end

function test_plain(n, l)
    @printf("test_plain begin [%d, %d]\n", n, l)
    for i = 1:n
        if i % 10 == 0
            println(i)
        end
        key = collect2(Uint8, take(3, rands(Uint8)))
        plain = collect2(Uint8, take(l, rands(Uint8)))
        cipher = encrypt(key, plain)
        oracle = plain_oracle(cipher, plain)
        keys = collect(force3(oracle, plain, cipher))
        if length(keys) != 1
            @printf("%s: %d\n", to_hex(key), length(keys))
        end
    end
    println("test_plain end")
end


function counting_oracle(key, counter)
    function oracle(k)
        counter[1] = counter[1] + 1
        k == key
    end
end

function test_counting_random(n)
    @printf("test_counting_random begin [%d]\n", n)
    counter = [0]
    for i = 1:n
        if i % 100 == 0
            println(i)
        end
        key = collect2(Uint8, take(3, rands(Uint8)))
        plain = Uint8[rand(Uint8)]
        cipher = encrypt(key, plain)
        oracle = counting_oracle(key, counter)
        keys = collect(force3(oracle, plain, cipher))
        if length(keys) != 1
            @printf("%s: %s/%s %d\n", to_hex(key), to_hex(plain), to_hex(cipher), length(keys))
        end
    end
    @printf("total trials: %d\n", counter[1])
    @printf("av trials per key: %.1f\n", counter[1] / n)
    @printf("av bits per key: %.1f\n", log(counter[1] / n) / log(2))
    @printf("av bits saved per key: %.1f\n", 24 - log(counter[1] / n) / log(2))
    println("test_counting_random end")
end


function test_duplicates(n, l)

    # extend test_plain to check that a second plaintext also encrypts
    # identically - not all do, so we print stats.

    @printf("test_duplicates begin [%d, %d]\n", n, l)
    count = 0
    for i = 1:n
        if i % 10 == 0
            println(i)
        end
        key = collect2(Uint8, take(3, rands(Uint8)))
        plain = collect2(Uint8, take(l, rands(Uint8)))
        cipher = encrypt(key, plain)
        oracle = plain_oracle(cipher, plain)
        keys = collect(force3(oracle, plain, cipher))
        if length(keys) != 1
            count = count + 1
            @printf("%s: %d\n", to_hex(key), length(keys))
            plain2 = collect2(Uint8, take(l, rands(Uint8)))
            cipher2 = encrypt(key, plain2)
            @printf("check with %s\n", to_hex(plain2))
            for other in keys
                cipher3 = encrypt(other, plain2)
                @printf("%s: %s\n", to_hex(other), to_hex(cipher3))
            end
            for other in keys
                if other != key
                    check_pair(100, 16, key, other, 1)
                    check_pair(100, 16, key, other, 3)
                end
            end
        end
    end
    @printf("duplicates: %d/%d\n", count, n)
    println("test_duplicates end")
end

function check_pair(n, l, key1, key2, d)
    count = 0
    for i = 1:n
        plain = collect2(Uint8, take(l, rands(Uint8)))
        cipher1 = encrypt(key1, plain)
        cipher2 = encrypt(key2, plain)
        if cipher1[d:] == cipher2[d:]
            count += 1
        end
    end
    @printf("%s / %s: %4.1f%% of ciphertext match after %d characters (sample size %d)\n", 
            to_hex(key1), to_hex(key2), 100 * count / n, d - 1, n)
end

        
function tests()
    println("BruteForce")
#    test_exact()
#    test_exact_random(1000)
#    test_plain(100, 16)
#    test_counting_random(1000)  # almost exactly 8 bits saved per key
#    test_duplicates(500, 16)
end

end
