
module Tasks2

export produce2, consume2

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

end
