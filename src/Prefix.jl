
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
    n1, n2, s
end

function random_stats()
    println("random_stats begin")
    for plain in [counter, zero() = constant(0x0), random() = rands(Uint8)]
        for i = 1:10
            key = collect2(Uint8, take(3, rands(Uint8)))
            n1, n2, s = loop_stats(key, plain())
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
        n1, n2, s = loop_stats(key, counter(), hash=no_count_hash)
        @printf("%s %d/%d\n", to_hex(key), n1, n2)
    end
    println("no_count_stats end")
end

# which shows some 1-cycle keys.  let's try get some idea of how often
# those occur.

function no_count_distribution(key_length)
    println("no_count_distribution begin")
    min, delay, count, n = 1e9, 0, 0, 0
    for i = 1:100
        n1, n2, s = loop_stats(take(key_length, rands(Uint8)), 
                               counter(), hash=no_count_hash)
        if n2 < min
            min, delay, count = n2, n1, 0
        elseif n2 == min
            count = count + 1
            delay = max(delay, n1)
        end
        if n2 == 1
            println(s)
        end
    end
    @printf("key length %d; smallest loop is %d (after max delay %d); occurs %d%% of the time\n",
            key_length, min, delay, count)
    println("no_count_distribution end")    
end

# so 1/10 of 3 byte keys, 1/3 for larger.
# most common state for 3 bytes is 000000 0/00 1/00 1/00
# for 4 bytes is 00000000 0/00 1/00 1/00
# for 8 bytes, many zeroes.
# maximum delays 31, 124, 716

function is_zero(s::State)
    zero = (s.pos_a == 0 && s.pos_b == 1 && s.pos_c == 1 && 
            all(map(x -> x == 0, s.key)))
    zero
end

# can we force more towards this by adding some (random?) value then
# another counter?

function zero_count(key_length, plain, n, label)
    count = 0
    for i = 1:n
        s = State(take(key_length, rands(Uint8)))
        collect(encrypt(s, plain()))
        count = count + (is_zero(s) ? 1 : 0)
    end
    @printf("%d (key %d) %s: %d\n", n, key_length, label, count)
end

function recounter(run, repeat)
    Task() do 
        c = counter()
        for i = 0:(repeat*run-1)
            n = consume(c)
            if bool(i % run)
                produce(n)
            else
                produce(rand(Uint8))
#                produce((n+1) & 0xff)
#                produce((n+2) & 0xff)
            end
        end
    end
end

function zero_counts()
    println("zero_counts begin")
    n = 100000
    zero_count(3, () -> take(32, counter()), n, "count 32")
    zero_count(3, () -> take(33*2, recounter(33, 2)), n, "recount 33/2")
    zero_count(3, () -> take(33*3, recounter(33, 3)), n, "recount 33/3")
    zero_count(4, () -> take(150, counter()), n, "count 150")
    zero_count(4, () -> take(150*2, recounter(150, 2)), n, "recount 150/2")
    zero_count(4, () -> take(150*3, recounter(150, 3)), n, "recount 150/3")
    zero_count(8, () -> take(800, counter()), n, "count 800")
    zero_count(8, () -> take(800*2, recounter(800, 2)), n, "recount 800/2")
    zero_count(8, () -> take(800*3, recounter(800, 3)), n, "recount 800/3")
    println("zero_counts end")
end

# 100000 (key 3) count 32: 3928
# 100000 (key 3) recount 33/2: 3858
# 100000 (key 3) recount 33/3: 3777
# 100000 (key 4) count 150: 4644
# 100000 (key 4) recount 150/2: 5891
# 100000 (key 4) recount 150/3: 6610
# 100000 (key 8) count 800: 1
# 100000 (key 8) recount 800/2: 1
# 100000 (key 8) recount 800/3: 2


function tests()
    println("Prefix")
#    random_stats()
#    no_count_stats()
#    no_count_distribution(3)
#    no_count_distribution(4)
#    no_count_distribution(8)
#    zero_counts()
end

end
