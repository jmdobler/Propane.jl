module Events

import ..Basetypes: Material
import DataStructures: BinaryMinMaxHeap
export PhaseEndTime, Order, EventSystem


abstract type TimedEvent end

struct PhaseEndTime <: TimedEvent
    phasename::String
    endtime::Float64
end

struct Order <: TimedEvent
    product::Material
    quantity::Float64
    endtime::Float64
end

function Order(productname::String, quantity::Float64, endtime::Float64)
    return Order(Material(1, productname), quantity, endtime)
end

function Base.isless(x::T, y::T) where T <: TimedEvent
    return x.endtime < y.endtime
end

struct EventSystem
    events::BinaryMinMaxHeap{TimedEvent}
end

function EventSystem()
    return EventSystem(BinaryMinMaxHeap{TimedEvent}())
end

Base.push!(es::EventSystem, event::T) where T <: TimedEvent= push!(es.events, event)
Base.pop!(es::EventSystem) = pop!(es.events)


end # module Events