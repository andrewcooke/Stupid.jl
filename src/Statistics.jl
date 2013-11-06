
module Statistics
using Cipher, Tasks2, Rand2, NHST, LittleBrother

export tests


function stats8(n, m, source)
    for j = 1:m
        data = source()
        @printf("n: %d; mean: %3.1f; std: %3.1f; bytes: %4.2f\n", 
                n, mean(data), std(data), chisq8(data))
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

function show_stats(n, key_length, label, m, plain; enc=encrypt)
    @printf("%s [%d]\n", label, key_length)
    key = () -> collect2(Uint8, take(key_length, rands(Uint8)))
    stats8(n, m, () -> collect2(Uint8, take(n, enc(key(), plain()))))
    stats2(n, m, () -> collect2(Uint8, take(n, enc(key(), plain()))))
end


function tests()
    println("Statistics")
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

end
