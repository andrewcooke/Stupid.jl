
module BitCorrelation
using LittleBrother, BitDistance, Tasks2, Gadfly, DataFrames, Cipher

export tests


# bitwise correlation.  equivalent (to within a constant scale factor)
# to expressing the two signals (cipher and counter) as streams of
# bits, replacing 0 with -1, and doing a "normal" cross-correlation at
# byte-size offsets.

function correlate(cipher, offset)
    offset = offset < 0 ? offset + 255 : offset
    c = 0
    for (a, b) in zip(cipher, counter(offset))
        c = c + BITS[(0xff $ a $ b) & 0xff + 1] - 4
    end
    c
end

function correlations(n, key_length)
    key, cipher = consume(take(1, encrypt_file(key_length)))
    Task() do
        for i = -n:n
            produce((key, i, correlate(cipher, i)))
        end
    end
end

function show_correlation(n, key_length)
    @printf("show_correlation begin [%d]\n", key_length)
    for (i, c) in correlations(n, key_length)
        @printf("%2d: %5d\n", i, c)
    end
    println("show_correlation end")
end

function plot_correlation(prefix, n, key_length)
    data = collect(zip(correlations(n, key_length)...))
    offset = [data[2]...]
    correlation = [data[3]...]
    draw(PNG(@sprintf("%s-%s.png", prefix, to_hex(data[1][1])), 15cm, 10cm),
         plot(DataFrame(offset=offset, correlation=correlation), 
              x="offset", y="correlation", Geom.point)) #, Geom.smooth))
end

function plot_correlations()
    println("plot_correlations begin")
    plot_correlation("bit-correlation-3", 128, 3)
    plot_correlation("bit-correlation-8", 128, 8)
    println("plot_correlations end")
end

function tests()
    println("BitCorrelation")
#    show_correlation(10, 3)
    plot_correlations()
end

end
