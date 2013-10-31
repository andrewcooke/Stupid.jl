
module Tasks2
using Rand2

export produce2, consume2, collect2, take, choices, repeat, constant,
iterate, counter

function produce2(v)
    ct = current_task()
    q = ct.consumers
    if isa(q,Condition)
        # make a task waiting for us runnable again
        notify1(q)
    end
    r = yieldto(ct.last, v)
    ct.parent = ct.last  # always exit to last consumer
    r
end
produce2(v...) = produce2(v)

function consume2(P::Task, args...)
    while !(P.runnable || P.done)
        if P.consumers === nothing
            P.consumers = Condition()
        end
        wait(P.consumers)
    end
    ct = current_task()
    prev = ct.last
    ct.runnable = false
    v = yieldto(P, args...)
    ct.last = prev
    ct.runnable = true
    if P.done
        q = P.consumers
        if !is(q, nothing)
            notify(q, P.result)
        end
    end
    v
end

function collect2(T::Type, task)
    a = Array(T, 0)
    for v in task
        push!(a, v)
    end
    a
end

function take(n, source)
    function task()
        while n > 0
            produce2(consume2(source))
            n = n - 1
        end
    end

    Task(task)
end

function repeat(f)
    function task()
        while true
            produce2(f())
        end
    end

    Task(task)
end

function choices(alphabet)
    repeat(() -> choice(alphabet))
end

function constant(n)
    repeat(() -> n)
end

function iterate(seq)
    function task()
        for s in seq
            produce2(s)
        end
    end

    Task(task)
end

function counter(start=0)
    repeat() do
        save = start
        start = start + 0x1
        save
    end
end


function test_counter()
    c = collect(take(3, counter()))
    @assert c == [0, 1, 2] c
    println("test_counter ok")
end

function tests()
    println("Tasks2")
    test_counter()
end

end
