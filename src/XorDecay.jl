
module XorDecay
using Tasks2, Rand2

export tests

function print_state(n, s)
    @printf("   %3d: ", n)
    for i = 1:length(s)
        @printf(" %02x", s[i])
    end
    println()
end

function print_xor(i)
    @printf("                       \$%d <- \$%d ^ \$%d\n", 
            i[1]-1, i[1]-1, i[2]-1)
end

function print_rotate(i)
    @printf("                       rotate \$%d\n", i)
end

function decay(n)
    state = collect2(Uint8, take(n, rands(Uint8)))
    n = 0
    while state != zeros(Uint8, length(state))
        print_state(n, state)
        indices = collect(take(2, choices([1:length(state)])))
        print_xor(indices)
        state[indices[1]] = state[indices[1]] $ state[indices[2]]
        print_state(n, state)
        print_rotate(indices[2])
        state[indices[2]] = state[indices[2]] << 7 | state[indices[2]] >> 1
        n = n + 1
    end
    print_state(n, state)
end


function tests()
    println("XorDecay")
#    decay(3)
#    decay(4)
#    decay(5)
end

end
