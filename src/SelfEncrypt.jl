
module SelfEncrypt
using Cipher, Tasks2, Rand2

export tests

# the idea here is that after some time state from the plaintext comes
# to dominate the initial key state.  so all ciphertexts for the same
# plaintext should tend towards a single limit.

# measure that limit for "real" text (little brother).

function encrypt_file(key_length)
    plain = open(readbytes, "../little-brother.txt")
    repeat() do
        key = collect2(Uint8, take(key_length, rands(Uint8)))
        cipher = encrypt(key, plain)
        key, cipher
    end
end

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
    for key in keys(results)
        @printf("%s: %d\n", to_hex(key), length(get(results, key, [])))
    end
    @printf("%d/%d\n", length(results), n)
    println("count_files end")
end

# shows that 100 keys give 82 results.  that's not good, but it
# suggests we're unlikely to find many sub-matches (since
# synchronisation with the plaintext is weak).


function tests()
    println("SelfEncrypt")
#    show_files(10, 3)
#    show_files(10, 8)
#    count_files(100, 3)  # 82
#    count_files(100, 8)  # 100
end

end
