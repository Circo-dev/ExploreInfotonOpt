# This Circo sample creates a linked list of actors holding float values,
# and calculates the sum of them over and over again.
# Its goal is testing cluster functions and for analyzing infoton optimization strategies.

module LinkedListTest

export conf, setconf, Coordinator

using Circo, Circo.Debug, Dates, Random, LinearAlgebra

include("commons.jl")

include("linkedlist_config.jl")
using .SearchTreeConf


# Test coordinator: Creates the list and sends the reduce operations to it to calculate the sum
mutable struct Coordinator{TCore} <: TestActor{TCore}
    itemcount::Int
    runidx::Int
    isrunning::Bool
    avgreducetime::Float64
    lastreducets::UInt64
    list::Addr
    resultcount::UInt64
    lastreportts::UInt64
    core::TCore
    Coordinator(core) = new{typeof(core)}(0, 0, false, 0.0, 0, Addr(), 0, 0, core)
end

boxof(addr) = !isnothing(addr) ? addr.box : nothing # Helper

# Implement Circo.monitorextra() to publish part of an actor's state
Circo.monitorextra(me::Coordinator)  = (
    itemcount = me.itemcount,
    avgreducetime = me.avgreducetime,
    list = boxof(me.list)
)
Circo.monitorprojection(::Type{<:Coordinator}) = JS("{
    geometry: new THREE.SphereBufferGeometry(25, 7, 7),
    color: 0xcb3c33
}")

mutable struct LinkedList{TCore} <: TestActor{TCore}
    head::Addr
    length::UInt64
    core::TCore
    LinkedList(head, core) = new{typeof(core)}(head, 0, core)
end

Circo.monitorprojection(::Type{<:LinkedList}) = JS("{
    geometry: new THREE.BoxBufferGeometry(20, 20, 20),
    color: 0x9558B2
}")

mutable struct ListItem{TData, TCore} <: TestActor{TCore}
    data::TData
    prev::Addr
    next::Addr
    core::TCore
    ListItem(data, core) = new{typeof(data), typeof(core)}(data, Addr(), Addr(), core)
end
Circo.monitorextra(me::ListItem) = (
    data = isdefined(me, :data) ? me.data : "undefined",
    next = isdefined(me, :next) && !isnothing(me.next) ? boxof(me.next) : nothing
)

Circo.monitorprojection(::Type{<:ListItem}) = JS("{
    geometry: new THREE.BoxBufferGeometry(10, 10, 10)
}")

include("infotonopt.jl")

struct Append <: Request
    replyto::Addr
    item::Addr
    token::Token
    Append(replyto, item) = new(replyto, item, Token())
end

struct Appended <: Response
    token::Token
end

struct SetNext #<: Request
    value::Addr
    token::Token
    SetNext(value::Addr) = new(value, Token())
end

struct SetPrev #<: Request
    value::Addr
    token::Token
    SetPrev(value::Addr) = new(value, Token())
end

struct Setted <: Response
    token::Token
end

struct Reduce{TOperation, TResult}
    op::TOperation
    result::TResult
end

struct Ack end

Sum() = Reduce(+, 0)
Mul() = Reduce(*, 1)

function Circo.onmessage(me::LinkedList, message::Append, service)
    send(service, me, message.item, SetNext(me.head))
    send(service, me, me.head, SetPrev(message.item))
    send(service, me, message.replyto, Appended(token(message)))
    me.head = message.item
    me.length += 1
end

function Circo.onspawn(me::Coordinator, service)
    cluster = getname(service, "cluster")
    @info "Coordinator scheduled on cluster: $cluster Building list of $(conf[].LIST_LENGTH) actors"
    list = LinkedList(addr(me), emptycore(service))
    me.itemcount = 0
    spawn(service, list)
    me.list = addr(list)
    appenditem(me, service)
end

function appenditem(me::Coordinator, service)
    item = ListItem(1.0 + me.itemcount * 1e-7, emptycore(service))
    spawn(service, item)
    send(service, me, me.list, Append(addr(me), addr(item)))
end

function Circo.onmessage(me::Coordinator, message::Appended, service)
    me.core.pos = nullpos
    me.itemcount += 1
    if me.itemcount < conf[].LIST_LENGTH
        appenditem(me, service)
    end
end


function Circo.onmessage(me::Coordinator, message::Run, service)
    @info "Got message: Run"
    if !me.isrunning
        me.isrunning = true
        me.lastreducets = time_ns()
        startbatch(me, service)
    end
end

function Circo.onmessage(me::Coordinator, message::Stop, service)
    @info "Got message: Stop"
    me.isrunning = false
end

Circo.onmessage(me::ListItem, message::SetNext, service) = me.next = message.value

Circo.onmessage(me::ListItem, message::SetPrev, service) = me.prev = message.value

Circo.onmessage(me::LinkedList, message::Reduce, service) = send(service, me, me.head, message)

function Circo.onmessage(me::Coordinator, message::RecipientMoved, service)
    if me.list == message.oldaddress
        me.list = message.newaddress
    end
    send(service, me, message.newaddress, message.originalmessage)
end

function Circo.onmessage(me::LinkedList, message::RecipientMoved, service) # TODO a default implementation like this
    if me.head == message.oldaddress
        @debug "RM List: head: $(me.head) msg: $message"
        me.head = message.newaddress
        send(service, me, me.head, message.originalmessage)
    else
        @debug "RM List: forwarding msg: $message"
        send(service, me, message.newaddress, message.originalmessage)
    end
end

function Circo.onmessage(me::ListItem, message::Reduce, service)
    newresult = message.op(message.result, me.data)
    send(service, me, me.next, Reduce(message.op, newresult))
    #if isdefined(me, :prev)
    #    send(service, me, me.prev, Ack())
    #end
end

Circo.onmessage(me::ListItem, message::Ack, service) = nothing

function Circo.onmessage(me::ListItem, message::RecipientMoved, service)
    if me.next == message.oldaddress
        @debug "RM: next: $(me.next) msg: $message"
        me.next = message.newaddress
        send(service, me, me.next, message.originalmessage)
    elseif isdefined(me, :prev) && me.prev == message.oldaddress
        @debug "RM: prev: $(me.prev) msg: $message"
        me.prev = message.newaddress
        send(service, me, me.prev, message.originalmessage)
    else
        @debug "RM: forwarding msg: $message"
        send(service, me, message.newaddress, message.originalmessage)
    end
end

function startbatch(me::Coordinator, service)
    me.runidx = 1
    for i = 1:conf[].PARALLELISM
        sumlist(me, service)
    end
    return nothing
end

function sumlist(me::Coordinator, service)
    send(service, me, me.list, Sum())
end

function mullist(me::Coordinator, service)
    send(service, me, me.list, Mul())
end

const alpha = 1e-3
function Circo.onmessage(me::Coordinator, message::Reduce, service)
    #me.core.pos = Pos(900, 0, 0)
    ts = time_ns()
    reducetime = ts - me.lastreducets
    me.lastreducets = ts
    me.avgreducetime = me.avgreducetime < 1e-3 ? Float64(reducetime) : (1.0 - alpha) * me.avgreducetime + alpha * Float64(reducetime)
    me.resultcount += 1
    #if rand(UInt8) == 0
    #    @info "Avg reduce time of $(me.itemcount): $(me.avgreducetime / 1e6)ms"
    #end
    if me.isrunning
        sumlist(me, service)
    end
end

end
