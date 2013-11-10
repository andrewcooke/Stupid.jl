
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
        c = c + nbits(0xff $ a $ b) - 4
    end
    c
end

function counter_correlations(shift, key_length)
    key, cipher = consume(take(1, encrypt_file(key_length)))
    Task() do
        for i = -shift:shift
            produce((key, i, counter_correlate(cipher, i)))
        end
    end
end

function show_counter_correlation(shift, key_length)
    @printf("show_counter_correlation begin [%d]\n", key_length)
    for (key, i, c) in counter_correlations(shift, key_length)
        @printf("%s %2d: %5d\n", to_hex(key), i, c)
    end
    println("show_counter_correlation end")
end

function plot_counter_correlation(prefix, shift, key_length)
    data = collect(zip(counter_correlations(shift, key_length)...))
    offset = [data[2]...]
    correlation = [data[3]...]
    draw(PNG(@sprintf("%s-%s.png", prefix, to_hex(data[1][1])), 15cm, 10cm),
         plot(DataFrame(offset=offset, correlation=correlation), 
              x="offset", y="correlation", Geom.point))
end

function plot_counter_correlations()
    println("plot_counter_correlations begin")
    plot_counter_correlation("counter-correlation-3", 128, 3)
    plot_counter_correlation("counter-correlation-8", 128, 8)
    println("plot_counter_correlations end")
end

# just for kicks, let's look at the correlation with plaintext.

function plot_plain_correlation(n, shift, key_length, mask)
    println("plot_plain_correlation begin")
    offset, correlation, zero = Int[], Int[], Bool[]
    correcn = nbits(mask) / 2
    for j = 1:n
        println(j)
        key, cipher = consume(take(1, encrypt_file(key_length)))
        plain = read_file()
        for i = -shift:shift
            clo = i < 0 ? 1 : i+1
            chi = length(cipher) - (i > 0 ? 0 : -i)
            plo = i < 0 ? 1-i : 1
            phi = length(plain) - (i > 0 ? i : 0)
            c = 0
            for (a, b) in zip(cipher[clo:chi], plain[plo:phi])
                c = c + nbits((0xff $ a $ b) & mask) - correcn
            end
            push!(offset, i)
            push!(zero, i == 0)
            push!(correlation, c)
        end
    end
    draw(PNG(@sprintf("plain-corelate-%d-%x.png", key_length, mask),
             15cm, 10cm),
         plot(DataFrame(offset=offset, correlation=correlation, zero=zero), 
              x="offset", y="correlation", color="zero", Geom.point))
    println("plot_plain_correlation end")
end



function tests()
    println("BitCorrelation")
#    show_counter_correlation(10, 3)
#    plot_counter_correlations()
#    plot_plain_correlation(5, 10, 3, 0xff)
#    plot_plain_correlation(5, 10, 4, 0xff)
#    plot_plain_correlation(5, 10, 8, 0xff)
#    plot_plain_correlation(5, 10, 8, 0x03)
#    plot_plain_correlation(5, 10, 8, 0xfc)
#    plot_plain_correlation(5, 10, 9, 0xff)
end

end
