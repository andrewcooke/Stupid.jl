
module Statistics
using Cipher, Tasks2, Rand2, NHST, LittleBrother, Prefix, BitDistance

export tests


function stats8(n, m, source)
    for j = 1:m
        data = source()
        @printf("n: %d; mean: %3.1f; std: %3.1f; bytes: %4.2f; crln: %4.2f\n", 
                n, mean(data), std(data), chisq8(data), correln(data))
        c2 = chisq2(data)
    end
end

function chisq8(data)
    bins = zeros(Int, 256)
    for d in data
        bins[d+1] = bins[d+1] + 1
    end
#    show(bins)
#    println()
    return run(ChisqTest, bins).p_value
end

function correln(data)
    mean(map(ab -> nbits(ab[1] $ ab[2]), zip(data, data[2:])))
end

function stats2(n, m, source)
    for j = 1:m
        data = source()
        c2 = chisq2(data)
        print("bits")
        for i = 1:8
            @printf("; %d: %4.2f", i-1, c2[i])
        end
        println()
    end
end

function chisq2(data)
    bins = [zeros(Int, 2) for i in 1:8]
    for d in data
        b = 1
        for i = 1:8
            j = d & b == 0x0 ? 1 : 2
            bins[i][j] = bins[i][j] + 1
            b = b << 1
        end
    end
#    show(bins)
#    println()
    collect(map(bin -> run(ChisqTest, bin).p_value, bins))
end

function loops(key_length, m, plain)
    mn, nmn, sm, n = 1e9, 0, 0, 0
    for i = 1:m
        k = collect2(Uint8, take(key_length, rands(Uint8)))
        try
            n1, n2 = loop_stats(k, plain(), hash=no_count_hash, limit=10000)
            if n2 < mn
                mn = n2
                nmn = 1
            elseif n2 == mn
                nmn = nmn + 1
            end
            sm = sm + n2
            n = n + 1
        catch
        end
    end
    @printf("%3d/%3d  min: %d (%d); avg: %5.1f\n", n, m, mn, nmn, sm / n)
end

function show_stats(n, key_length, label, m, plain; enc=encrypt)
    @printf("%s [%d]\n", label, key_length)
    key = () -> collect2(Uint8, take(key_length, rands(Uint8)))
    stats8(n, m, () -> collect2(Uint8, take(n, enc(key(), plain()))))
    stats2(n, m, () -> collect2(Uint8, take(n, enc(key(), plain()))))
    loops(key_length, 100, plain)
end

function show_all()
    text = read_file()
    n = length(text)

    show_stats(n, 3, "\ncontrol", 3, () -> rands(Uint8), 
               enc=(k, p) -> rands(Uint8))

    show_stats(n, 3, "\nrandom",  3, () -> rands(Uint8))
    show_stats(n, 3, "\nzero",    3, () -> constant(0x0))
    show_stats(n, 3, "\n0x55",    3, () -> constant(0x55))
    show_stats(n, 3, "\n0xff",    3, () -> constant(0xff))
    show_stats(n, 3, "\ncounter", 3, () -> counter())
    show_stats(n, 3, "\ntext",    3, () -> iterate(text))

    show_stats(n, 8, "\nrandom",  3, () -> rands(Uint8))
    show_stats(n, 8, "\nzero",    3, () -> constant(0x0))
    show_stats(n, 8, "\n0x55",    3, () -> constant(0x55))
    show_stats(n, 8, "\n0xff",    3, () -> constant(0xff))
    show_stats(n, 8, "\ncounter", 3, () -> counter())
    show_stats(n, 8, "\ntext",    3, () -> iterate(text))

    show_stats(n, 16, "\nrandom",  3, () -> rands(Uint8))
    show_stats(n, 16, "\nzero",    3, () -> constant(0x0))
    show_stats(n, 16, "\n0x55",    3, () -> constant(0x55))
    show_stats(n, 16, "\n0xff",    3, () -> constant(0xff))
    show_stats(n, 16, "\ncounter", 3, () -> counter())
    show_stats(n, 16, "\ntext",    3, () -> iterate(text))
end

function show_state(n, f, key_length)
    for i = 1:n
        k  = 0
        while true
            k = k + 1
            s = State(collect2(Uint8, take(key_length, rands(Uint8))))
            p = counter(0x0)
            t = encrypt(s, p)
            n1, c = run_to_repeat(s, t, hash=no_count_hash)
            if n1 < 0
                continue
            end
            n2 = 0
            s2 = State(s)
            for j = 1:f
                n2, _ = run_to_repeat(s, t, hash=no_count_hash)
                if n2 != 1
                    break
                end
            end
            if n2 != 1
                continue
            end
            @printf("\ndiscard %d; after %d; cipher %02x\nstate %s\n", k, n1, c, s2)
            trace(s2, consume(p)-1)
            break
        end
    end    
end

function trace(state::State, plain; forwards=true)
    plain::Uint = plain & 0xff
    @printf("%80s\n", state)
    @printf("old_a = %02x\n", state.pos_a)
    old_a = state.pos_a
    @printf("%80s\n", state)
    @printf("pos_a = key[%02x] %% %02x = %02x %% %02x = %02x\n",
            state.pos_b, state.key_length, 
            state.key[state.pos_b+1], state.key_length, 
            state.key[state.pos_b+1] % state.key_length)
    state.pos_a = state.key[state.pos_b+1] % state.key_length
    @printf("%80s\n", state)
    @printf("pos_b = (pos_a + 1 + (key[%02x] %% %02x)) %% %02x = (%02x + 1 + (%02x %% %02x)) %% %02x = %02x\n",
            state.pos_c, state.key_length - 1, state.key_length,
            state.pos_a, state.key[state.pos_c+1], state.key_length - 1, state.key_length,
            (state.pos_a + 1 +
             state.key[state.pos_c+1] % (state.key_length - 1)
             ) % state.key_length)
    state.pos_b = (state.pos_a + 1 + 
                   state.key[state.pos_c+1] % (state.key_length - 1)
                   ) % state.key_length
    @printf("%80s\n", state)
    @printf("pos_c = (pos_a + 1 + (key[%02x] %% %02x)) %% %02x = (%02x + 1 + (%02x %% %02x)) %% %02x = %02x\n",
            old_a, state.key_length - 1, state.key_length,
            state.pos_a, state.key[old_a+1], state.key_length - 1, state.key_length,
            (state.pos_a + 1 + 
             state.key[old_a+1] % (state.key_length - 1)
             ) % state.key_length)
    state.pos_c = (state.pos_a + 1 + 
                   state.key[old_a+1] % (state.key_length - 1)
                   ) % state.key_length
    @printf("%80s\n", state)
    @printf("cipher = plain \$ key[%02x] \$ key[%02x] = %02x \$ %02x \$ %02x = %02x\n",
            state.pos_a, state.pos_b,
            plain, state.key[state.pos_a+1], state.key[state.pos_b+1],
            plain $ state.key[state.pos_a+1] $ state.key[state.pos_b+1])
    cipher::Uint8 = plain $ state.key[state.pos_a+1] $ state.key[state.pos_b+1]
    @printf("%80s\n", state)
    @printf("poison = %02x\n", forwards ? cipher : plain)
    poison = forwards ? cipher : plain
    @printf("key[%02x] = key[%02x] << 7 | key[%02x] >> 1 = %02x << 7 | %02x >> 1 = %02x\n",
            state.pos_c, state.pos_c, state.pos_c,
            state.key[state.pos_c+1], state.key[state.pos_c+1],
            (state.key[state.pos_c+1] << 7 | state.key[state.pos_c+1] >> 1))
    state.key[state.pos_c+1] = (state.key[state.pos_c+1] << 7 | 
                                state.key[state.pos_c+1] >> 1)
    @printf("%80s\n", state)
    @printf("key[%02x] = key[%02x] \$ key[%02x] \$ %02x \$ %02x = %02x\n", 
            state.pos_a, state.pos_a, state.pos_c, state.count, poison,
            (state.key[state.pos_a+1] $ state.key[state.pos_c+1] $ state.count $ poison))
    state.key[state.pos_a+1] = (state.key[state.pos_a+1] $ 
                                state.key[state.pos_c+1] $ 
                                state.count $ poison)
    @printf("%80s\n", state)
    @printf("count = %02x + 1 = %02x\n",
            state.count, state.count + 1)
    state.count = state.count + 1
    cipher
end


function tests()
    println("Statistics")
    show_all()
#    show_state(10, 1, 3)
end

end
