
module BruteForce
using Cipher, Tasks2, Rand2

export tests


function force3(cipher, oracle)
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
                                                key1 = cipher[1] $ key0  # infer key[pos_b]
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
                                                key2 = cipher[1] $ key0  # infer key[pos_b]
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
                                                key0 = cipher[1] $ key1  # infer key[pos_b]
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
                                                key2 = cipher[1] $ key1  # infer key[pos_b]
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
                                                key0 = cipher[1] $ key2  # infer key[pos_b]
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
                                                key1 = cipher[1] $ key2  # infer key[pos_b]
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
                                                key1 = cipher[1] $ key0  # infer key[pos_b]
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
                                                key2 = cipher[1] $ key0  # infer key[pos_b]
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
                                                key0 = cipher[1] $ key1  # infer key[pos_b]
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
                                                key2 = cipher[1] $ key1  # infer key[pos_b]
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
                                                key0 = cipher[1] $ key2  # infer key[pos_b]
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
                                                key1 = cipher[1] $ key2  # infer key[pos_b]
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
                                                key1 = cipher[1] $ key0  # infer key[pos_b]
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
                                                key2 = cipher[1] $ key0  # infer key[pos_b]
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
                                                key0 = cipher[1] $ key1  # infer key[pos_b]
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
                                                key2 = cipher[1] $ key1  # infer key[pos_b]
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
                                                key0 = cipher[1] $ key2  # infer key[pos_b]
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
                                                key1 = cipher[1] $ key2  # infer key[pos_b]
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
                                        key0 = cipher[1] $ key1  # infer key[pos_b]
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
                                        key2 = cipher[1] $ key1  # infer key[pos_b]
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
                                        key0 = cipher[1] $ key1  # infer key[pos_b]
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
                                        key2 = cipher[1] $ key1  # infer key[pos_b]
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
                                        key0 = cipher[1] $ key1  # infer key[pos_b]
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
                                        key2 = cipher[1] $ key1  # infer key[pos_b]
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
                                        key1 = cipher[1] $ key0  # infer key[pos_b]
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
                                        key2 = cipher[1] $ key0  # infer key[pos_b]
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
                                        key0 = cipher[1] $ key1  # infer key[pos_b]
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
                                        key2 = cipher[1] $ key1  # infer key[pos_b]
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
                                        key0 = cipher[1] $ key2  # infer key[pos_b]
                                        for key1 = 0:255
                                            if key1 % 3 == key1_mod_3
                                                key = Uint8[key0, key1, key2]
                                                if oracle(key)
                                                    produce(key)
                                                end
                                            end
                                        end
                                    elseif pos_b == 1
                                        key1 = cipher[1] $ key2  # infer key[pos_b]
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
                keys = collect(force3(cipher, oracle))
                if length(keys) != 1
                    @printf("%s: %d\n", to_hex(key), length(keys))
                end
            end
        end
    end
end

function test_exact_random(n)
    for i = 1:n
        if i % 100 == 0
            println(i)
        end
        key = collect2(Uint8, take(3, rands(Uint8)))
        cipher = encrypt(key, Uint8[0x0])
        oracle = exact_oracle(key)
        keys = collect(force3(cipher, oracle))
        if length(keys) != 1
            @printf("%s: %d\n", to_hex(key), length(keys))
        end
    end
end

        
function tests()
    println("BruteForce")
#    test_exact()
    test_exact_random(1000)
end

end
