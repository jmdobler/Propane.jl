module Events

import Dates: DateTime
import DataStructures: BinaryMinMaxHeap
import ..Basetypes: Material
export PhaseEndTime, Order, EventSystem
export Logger, logmessage!, logdata!                         # TODO: remove later

abstract type TimedEvent end

struct PhaseEndTime <: TimedEvent
    phasename::String
    endtime::DateTime
end

struct Order <: TimedEvent
    product::Material
    quantity::Float64
    endtime::DateTime
end

function Order(productname::String, quantity::Float64, endtime::DateTime)
    return Order(Material(productname), quantity, endtime)
end

function Base.isless(x::T, y::T) where T <: TimedEvent
    return x.endtime < y.endtime
end


struct Logger
    time::Vector{DateTime}
    data::Vector{Any}
    messages::Vector{String}
end

function Base.show(io::IO, logger::Logger)
    println(io, "Logger with $(length(logger.messages)) messages:") 
    for m in logger.messages
        println(io, repeat(" ", 4), m)
    end
    println(io, "Logger with $(length(logger.time)) entries:")  
    for (t, d) in zip(logger.time, logger.data)
        println(io, repeat(" ", 4), t, " => ", d)
    end
end

Logger() = Logger(Float64[], Any[], String[])

function logdata!(logger::Logger, time::DateTime, data::Any)
    push!(logger.time, time)
    push!(logger.data, data)
end

logmessage!(logger::Logger, message::String) = push!(logger.messages, message)



struct EventSystem
    events::BinaryMinMaxHeap{TimedEvent}
    logs::Logger
end

function EventSystem()
    return EventSystem(BinaryMinMaxHeap{TimedEvent}(), Logger())
end

Base.push!(es::EventSystem, event::T) where T <: TimedEvent= push!(es.events, event)
Base.pop!(es::EventSystem) = pop!(es.events)
Base.length(es::EventSystem) = length(es.events)

end # module Events