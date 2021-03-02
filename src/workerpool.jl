module WorkerPool

export conf, setconf, Coordinator
    
using Circo, Circo.Debug, Circo.Migration, Circo.Monitor, DataStructures, LinearAlgebra
using ..Commons

include("workerpool_config.jl")
using .WorkerPoolConf

# Test Coordinator that creates several worker pools
mutable struct Coordinator{TCoreState} <: TestActor{TCoreState}
    runmode::UInt8
    resultcount::UInt64
    lastreportts::UInt64
    pools::Vector{Addr}
    core::TCoreState
    Coordinator(core) = new{typeof(core)}(STOP, 0, 0, [], core)
end

Circo.monitorprojection(::Type{<:Coordinator}) = JS("{
    geometry: new THREE.SphereBufferGeometry(25, 7, 7),
    color: 0xcb3c33
}")

Circo.monitorextra(me::Coordinator)  = (
#    runmode=me.runmode,
#    root =!isnothing(me.root) ? me.root.box : nothing
)

function Circo.onspawn(me::Coordinator, service)
    for i = 1:conf[].POOL_COUNT
        push!(me.pools, spawn(service, Pool(conf[].POOL_SIZE, emptycore(service))))
    end
end

function Circo.onmessage(me::Coordinator, msg::Circo.Debug.Run, service)
    for pool in me.pools
        send(service, me, pool, msg)
    end
end

mutable struct Pool{TCore} <: TestActor{TCore}
    size::Int
    workers::Vector{Addr}
    core::TCore
    Pool(size, core) = new{typeof(core)}(size, [], core)
end

struct WorkTask
    difficulty::Float64
end

struct TaskDone
    task::WorkTask
    reporter::Addr
end

function Circo.onspawn(me::Pool, service)
    for i = 1:me.size
        push!(me.workers, spawn(service, Worker(addr(me), emptycore(service))))
    end
end

function start_task(me::Pool, service)
    send(service, me, rand(me.workers), WorkTask(rand()))
end

function Circo.onmessage(me::Pool, msg::RecipientMoved, service)
    idx = findfirst(a -> a == msg.oldaddress, me.workers)
    if !isnothing(idx)
        me.workers[idx] = msg.newaddress
    end
    send(service, me, msg.newaddress, msg.originalmessage)
end

function Circo.onmessage(me::Pool, msg::Circo.Debug.Run, service)
    for i = 1:conf[].PARALLELISM
        start_task(me, service)
    end
end

function Circo.onmessage(me::Pool, msg::TaskDone, service)
    start_task(me, service)
end

mutable struct Worker{TCore} <: TestActor{TCore}
    pool::Addr
    migration_target::Union{PostCode, Nothing}
    core::TCore
    Worker(pool, core) = new{typeof(core)}(pool, nothing, core)
end

Circo.monitorextra(me::Worker)  = (
    pool =!isnothing(me.pool) ? me.pool.box : nothing,
)

function Circo.onmessage(me::Worker, task::WorkTask, service)
    x = 0
    for i=1:task.difficulty * 1e5
        x += i
    end
    send(service, me, me.pool, TaskDone(task, addr(me)))
end

function Circo.onmessage(me::Worker, msg::RecipientMoved, service)
    if me.pool == msg.oldaddress
        me.pool = msg.newaddress
    end
    send(service, me, msg.newaddress, msg.originalmessage)
end

end # module
