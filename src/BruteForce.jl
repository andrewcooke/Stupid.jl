
module BruteForce
using Cipher

export tests


function Force3(cipher, oracle)
    Task() do
        for key_1_mod_3 = 0:2
            pos_b = key_1_mod_3 # how pos_b is first assigned
            if pos_b == 0
                for key_0_mod_3 = 0:2
                    pos_a = old_a = key_0_mod_3 # by chance these are both equal
                    if old_a == 0
                        for key_0_mod_2 = 0:1
                            # c is not needed (except the original value mod 2) - do b instead !!!!!!!!!!!
                            pos_c = (pos_a + 1 + key_0_mod_2) % 3
                            for key0 = 0:255
                                if key0 % 2 == key_0_mod_2 && key0 % 3 == key_0_mod_3
                                    keyc = cipher[0] $ key0
                                    if pos_c == 0
                                        # cannot happen as pos_a == 0
                                    elseif pos_c == 1
                                        key1 = keyc
                                        if key1 % 3 == key_1_mod_3
                                            for key2 = 0:255
                                                key = Uint8[key0, key1, key2]
                                                if oracle(key)
                                                    produce(key)
                                                end
                                            end
                                        end
                                    elseif pos_c == 2 
                                        key2 = keyc
                                        for key1 = 0:255
                                            if key1 % 3 == key_1_mod_3
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
                    elseif old_a == 1
                        for key_1_mod_2 = 0:1
                            pos_c = (pos_a + 1 + key_1_mod_2) % 3
                            for key1 = 0:255
                                if key1 % 2 == key_1_mod_2 && key1 % 3 == key_1_mod_3
                                    keyc == cipher[0] $ key1
                                    if pos_c == 0
                                        key0 = keyc
                                        if key0 % 3 == key_0_mod_3
                                            for key2 = 0:255
                                                key = Uint8[key0, key1, key2]
                                                if oracle(key)
                                                    produce(key)
                                                end
                                            end
                                        end
                                    elseif pos_c == 1
                                        # cannot happen as pos_a == 1
                                    elseif pos_c == 2
                                        key2 = keyc
                                        for key0 = 0:255
                                            if key0 % 2 == key_0_mod_2 && key0 % 3 == key_0_mod_3
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
                    elseif old_a == 2
                        for key_2_mod_2 = 0:1
                            pos_c = (pos_a + 1 + key_2_mod_2) % 3
                            for key2 = 0:255
                                if key2 % 2 == key_2_mod_2
                                    keyc = cipher[0] $ key2
                                    if pos_c == 0
                                        key0 = keyc
                                        if key0 % 3 == key_0_mod_3
                                            for key1 = 0:255
                                                if key1 % 2 == key_1_mod_2 && key1 % 3 == key_1_mod_3
                                                    key = Uint8[key0, key1, key2]
                                                    if oracle(key)
                                                        produce(key)
                                                    end
                                                end
                                            end
                                        end
                                    elseif pos_c == 1 
                                        key1 = keyc
                                        if key1 % 2 == key_1_mod_2 && key1 % 3 == key_1_mod_3
                                            for key0 = 0:255
                                                if key0 % 3 == key_0_mod_3
                                                    key = Uint8[key0, key1, key2]
                                                    if oracle(key)
                                                        produce(key)
                                                    end
                                                end
                                            end
                                        end
                                    elseif pos_c == 2
                                        # cannot happen as pos_a == 2
                                    end
                                end
                            end
                        end
                    end
                end
            elseif pos_b == 1
            elseif pos_b == 2
            end
        end
    end
end



end
