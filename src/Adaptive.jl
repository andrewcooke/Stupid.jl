
module Adaptive
using Cipher, Rand2, Tasks2, Prefix

export tests


# try to improve the attack in Prefix by providing plaintext that is
# calculated to cancel the current state (as much as possible).

function apply_attack(s, a; debug=false)
    while true
        prev = deepcopy(s)
        c = encrypt(s, 0x0)
        s = prev
        p = consume2(a, c)
        if p == nothing
            return s
        end
        encrypt(s, p, debug=debug)
    end
end

function score_attack(n, key_length, a; debug=false)
    count = 0
    for i = 1:n
        if is_zero(apply_attack(State(take(key_length, rands(Uint8))), a(),
                                debug=debug))
            count = count + 1
        end
    end
    count
end

function echo(n)
    Task() do c
        for i = 1:n
            c = produce2(c)
        end
    end
end

function count0(n)
    Task() do c
        for i = 1:n
            c = produce2(i-1)
        end
    end
end

function count1(n)
    Task() do c
        for i = 1:n
            c = produce2(i)
        end
    end
end

function both(n)
    Task() do c
        for i = 1:n
            c = produce2(c $ (i-1))
        end
    end
end


function show_attack(n, key_length, a, label; debug=false)
    count = score_attack(n, key_length, a, debug=debug)
    @printf("%20s [%d]  %d/%d\n", label, key_length, count, n)
end

function tests()
    println("Adaptive")
    n = 1000
    debug = false
    show_attack(n, 3, () -> echo(16), "echo(16)", debug=debug)
    show_attack(n, 3, () -> echo(32), "echo(32)", debug=debug)
    show_attack(n, 3, () -> echo(64), "echo(64)", debug=debug)
    show_attack(n, 3, () -> count0(32), "count0(32)", debug=debug)
    show_attack(n, 3, () -> count1(32), "count1(32)", debug=debug)
    show_attack(n, 3, () -> both(16), "both(16)", debug=debug)
    show_attack(n, 3, () -> both(32), "both(32)", debug=debug)
    show_attack(n, 3, () -> both(64), "both(64)", debug=debug)
end

end
