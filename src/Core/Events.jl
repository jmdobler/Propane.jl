module Events

import ..Basetypes: Material
import DataStructures: BinaryMinMaxHeap
export PhaseEndTime, Order, EventSystem
export Logger                                       # TODO: remove later

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
    return Order(Material(productname), quantity, endtime)
end

function Base.isless(x::T, y::T) where T <: TimedEvent
    return x.endtime < y.endtime
end



struct Logger
    time::Vector{Float64}
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

function logdata(time::Float64, data::Any, logger::Logger = LOGGER)
    push!(logger.time, time)
    push!(logger.data, data)
end

logmessage(message::String, logger::Logger = LOGGER) = push!(logger.messages, message)



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