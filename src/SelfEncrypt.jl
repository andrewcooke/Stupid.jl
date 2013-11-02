
module SelfEncrypt
using Cipher, Tasks2, Rand2, LittleBrother

export tests

# the idea here is that after some time state from the plaintext comes
# to dominate the initial key state.  so ciphertexts for the same
# plaintext tend towards a single limit.

# measure that limit for "real" text (little brother).

function show_files(n, key_length) 
    @printf("show_files begin [%d]\n", key_length)
    for (key, cipher) in take(n, encrypt_file(key_length))
        @printf("%s: ...%s\n", to_hex(key), to_hex(cipher[end-20:end]))
    end
    println("show_files end")
end

function count_files(n, key_length)
    @printf("count_files begin [%d]\n", key_length)
    results = Dict{Array{Uint8,1}, Array{Array{Uint8,1},1}}()
    for (key, cipher) in take(n, encrypt_file(key_length))
        tail = cipher[end-20:end]
        result = get(results, tail, Array(Array{Uint8,1}, 0))
        push!(results, tail, result)
        push!(result, key)
    end
    singles = 0
    for key in keys(results)
        count = length(get(results, key, []))
        @printf("%s: %d\n", to_hex(key), count)
        singles = singles + (count == 1 ? 1 : 0)
    end
    @printf("%d/%d (%d single)\n", length(results), n, singles)
    println("count_files end")
end

# shows that 100 keys (3 bytes) give ~80 results.  that's not good,
# but it suggests we're unlikely to find many sub-matches (since
# synchronisation with the plaintext is weak).


function tests()
    println("SelfEncrypt")
#    show_files(10, 3)
#    show_files(10, 8)
#    count_files(100, 3)  # 85/100 (72 single)
#    count_files(100, 8)  # 100
end

end
