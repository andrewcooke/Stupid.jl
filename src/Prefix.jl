
module Prefix
using BitDistance, Cipher, Gadfly, DataFrames, Rand2, Tasks2

export tests

# it seems that a counter plaintext can corrupt the state in some way
# (from experience with other approaches and buggy code). maybe we can
# then extract that state?  and then continue with plaintext which
# will be decryptable.

# first, see what the effect of the counter on state is by measuring
# the distance to repeated state with the counter plaintext.

function run_to_repeat(s, c, t; hash=hash)
    n = 0
    known = Set()
    while true
        h = hash(s)
        if in(h, known)
            return n
        end
        push!(known, h)
        n = n+1
        consume(t)
    end
end

function loop_stats(key, plain; debug=false, hash=hash)
    s = State(key)
    t = encrypt(s, plain, debug=debug)
    n1 = run_to_repeat(s, plain, t, hash=hash)
    n2 = run_to_repeat(s, plain, t, hash=hash)
#    if n2 <= 256
#        collect(take(5, encrypt(s, plain, debug=true)))
#    end
    n1, n2
end

function random_stats()
    println("random_stats begin")
    for plain in [counter, zero() = constant(0x0), random() = rands(Uint8)]
        for i = 1:10
            key = collect2(Uint8, take(3, rands(Uint8)))
            n1, n2 = loop_stats(key, plain())
            @printf("%s %d/%d %s\n", to_hex(key), n1, n2, 
                    Base.function_name(plain))
        end
    end
    println("random_stats end")
end

# of course, the above shows multiples of 256 because count is in the
# state.  but with a counter plaintext we can nullify that.  so let's
# focus on that.

function no_count_hash(s::State)
    h::Int64 = s.key_length
    h = h << 8 | s.pos_a
    h = h << 8 | s.pos_b
    h = h << 8 | s.pos_c
    for i = 1:s.key_length
        h = h << 8 | s.key[i]
    end
    h
end

function no_count_stats()
    println("no_count_stats begin")
    for i = 1:10
        key = collect2(Uint8, take(3, rands(Uint8)))
        n1, n2 = loop_stats(key, counter(), hash=no_count_hash)
        @printf("%s %d/%d\n", to_hex(key), n1, n2)
    end
    println("no_count_stats end")
end

# which shows some 1-cycle keys.  let's try get some idea of how often
# those occur.

function no_count_distribution(key_length)
    println("no_count_distribution begin")
    min, count = 1e9, 0
    for i = 1:100
        key = collect2(Uint8, take(key_length, rands(Uint8)))
        n1, n2 = loop_stats(key, counter(), hash=no_count_hash)
        if n2 < min
            min, count = n2, 0
        elseif n2 == min
            count = count + 1
        end
    end
    @printf("key length %d; smallest loop is %d; occurs %d%% of the time\n",
            key_length, min, count)
    println("no_count_distribution end")    
end

# so 1/10 of 3 byte keys, 1/3 for larger.

# presumably it's going to be easier to characterise the shortest
# cases, so let's catalogue those.



function tests()
    println("Prefix")
#    random_stats()
#    no_count_stats()
#    no_count_distribution(3)
#    no_count_distribution(4)
#    no_count_distribution(8)
end

end
