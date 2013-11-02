
module BitCorrelation
using LittleBrother, BitDistance, Tasks2, Gadfly, DataFrames, Cipher

export tests


# bitwise correlation.  equivalent (to within a constant scale factor)
# to expressing the two signals (cipher and counter) as streams of
# bits, replacing 0 with -1, and doing a "normal" cross-correlation at
# byte-size offsets.

function counter_correlate(cipher, offset)
    offset = offset < 0 ? offset + 255 : offset
    c = 0
    for (a, b) in zip(cipher, counter(offset))
        c = c + BITS[(0xff $ a $ b) & 0xff + 1] - 4
    end
    c
end

function counter_correlations(n, key_length)
    key, cipher = consume(take(1, encrypt_file(key_length)))
    Task() do
        for i = -n:n
            produce((key, i, counter_correlate(cipher, i)))
        end
    end
end

function show_counter_correlation(n, key_length)
    @printf("show_counter_correlation begin [%d]\n", key_length)
    for (key, i, c) in counter_correlations(n, key_length)
        @printf("%s %2d: %5d\n", to_hex(key), i, c)
    end
    println("show_counter_correlation end")
end

function plot_counter_correlation(prefix, n, key_length)
    data = collect(zip(counter_correlations(n, key_length)...))
    offset = [data[2]...]
    correlation = [data[3]...]
    draw(PNG(@sprintf("%s-%s.png", prefix, to_hex(data[1][1])), 15cm, 10cm),
         plot(DataFrame(offset=offset, correlation=correlation), 
              x="offset", y="correlation", Geom.point)) #, Geom.smooth))
end

function plot_counter_correlations()
    println("plot_counter_correlations begin")
    plot_counter_correlation("bit-correlation-3", 128, 3)
    plot_counter_correlation("bit-correlation-8", 128, 8)
    println("plot_counter)correlations end")
end

# just for kicks, let's look at the correlation with plaintext.

function plain_correlate(cipher, plain)
    c
end

function plot_plain_correlation(n, key_length)
    println("plot_plain_correlation begin")
    key, cipher = consume(take(1, encrypt_file(key_length)))
    plain = read_file()
    offset, correlation = Int[], Int[]
    for i = -n:n
        clo = i < 0 ? 1 : i+1
        chi = length(cipher) - (i > 0 ? 0 : -i)
        plo = i < 0 ? 1-i : 1
        phi = length(plain) - (i > 0 ? i : 0)
        @printf("%d  %d:%d %d  %d:%d %d\n", 
                i, clo, chi, chi - clo, plo, phi, phi - plo)
        c = 0
        for (a, b) in zip(cipher[clo:chi], plain[plo:phi])
            c = c + BITS[(0xff $ a $ b) & 0xff + 1] - 4
        end
        push!(offset, i)
        push!(correlation, c)
    end
    draw(PNG(@sprintf("plain-corelate-%d-%s.png", key_length, to_hex(key)),
             15cm, 10cm),
         plot(DataFrame(offset=offset, correlation=correlation), 
              x="offset", y="correlation", Geom.point)) #, Geom.smooth))
    println("plot_plain_correlation end")
end

# nada...


function tests()
    println("BitCorrelation")
#    show_counter_correlation(10, 3)
#    plot_counter_correlations()
    plot_plain_correlation(20, 3)
end

end
