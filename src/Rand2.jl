
module Rand2
using Tasks2

export choice, rands, choices, tests


function choice(all)
    all[rand(1:length(all))]
end

function choices(all)
    Task() do
        while length(all) > 0
            produce(splice!(all, rand(1:length(all))))
        end
    end
end

function rands{T<:Integer}(::Type{T})
    repeat(() -> rand(T))
end


function test_choice()
    n = choice([1,2,3])
    @assert n > 0 && n < 4 n
    println("test_choice ok")
end

function test_rands()
    r = rands(Uint8)
    n = consume2(r)
    @assert typeof(n) == Uint8 n
    ns = collect(take(4, r))
    @assert length(ns) == 4 ns
    println("test_rands ok")
end

function tests()
    test_choice()
    test_rands()
end

end
