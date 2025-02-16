module PropaneCore

include("Core/Basetypes.jl")
using .Basetypes

include("Core/Events.jl")
using .Events

include("Core/Stages.jl")
using .Stages

include("Core/EquipmentUnits.jl")
using .EquipmentUnits

include("Core/Phases.jl")
using .Phases

include("Core/Scopes.jl")
using .Scopes



export Scope, SCOPE, phases, stages, units, process_summary, scopesummary, within
export Stage, @Stage 
export Unit, @Unit
export Material, Storage, STORAGE, inventory
export Process, @Process, CURRENT_PROCESS, Phase, @Phase, CURRENT_PHASE, take, @take, supply, @supply, source, @source
export Simulation, placeorder, run 

# Todo: Phase Parameter definition, eg volume
# Todo: Phase Quantity normalisation by target amount or only @taking relative wt's and vol's
# Todo: Add resources and use @implement to assign a ressource to a (Phase or Stage)
# Todo: Scale Phases by either 
# Todo: Phase Status: optional, urgent, inactive / idle, processing ...
# Todo: Log results from run()
# Todo: Access logged results within a dataframe / plot
# Todo: Add time tracking
# Todo: orchestrate Phases based on Status





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






















function urgent(phase::Phase)
    supplied_stages = Float64[]
    for s in phase.outputs
        push!(supplied_stages, _getstage(s).allocation)
    end
    if isempty(supplied_stages)
        return false
    else
        return minimum(supplied_stages) < 0
    end
end

function process_summary(scope::Scope = SCOPE)
    ret = String[]
    for p in scope.phases
        push!(ret, p.process)
    end
    for s in scope.stages
        push!(ret, s.process)
    end
    return unique(ret)
end 

struct Storage
    materials::Dict{Material, Float64}
end

Base.getindex(storage::Storage, materialname::String) = for mat in keys(storage.materials) if mat.name == materialname return mat end end

STORAGE = Storage(Dict{Material, Float64}())

function inventory(storage::Storage = STORAGE)
    return [(key.name, value) for (key, value) in storage.materials if value != 0.0]
end


function take(action::Pair{String, Float64}, scalefactor::Float64 = 1.0)
    # somehow address the phase interactions value * scale
    material = STORAGE[action[1]]
    quantity = action[2] * scalefactor
    if material !== nothing
        STORAGE.materials[material] -= quantity
    else
        STORAGE.materials[Material(0, action[1])] = -quantity
    end
end

function supply(action::Pair{String, Float64}, scalefactor::Float64 = 1.0)
    stage = _getstage(action[1])
    stage !== nothing ? stage.allocation += action[2] * scalefactor : error("Stage $(action[1]) does not exist")       # does that work?
    # stage.allocation += action[2] * scalefactor
end

function source(action::Pair{String, Float64}, scalefactor::Float64 = 1.0)
    stage = _getstage(action[1])
    stage !== nothing ? stage.allocation -= action[2] * scalefactor : error("Stage $(action[1]) does not exist")       # does that work?
end



function _getstage(stagename::String, scope::Scope = SCOPE)
    stageindices = findall(stage -> stage.name == stagename, scope.stages)
    if !isempty(stageindices)
        return scope.stages[first(stageindices)]
    else
        return nothing
    end
end

function _getphase(phasename::String, scope::Scope = SCOPE)
    phaseindices = findall(phase -> phase.name == phasename, scope.phases) 
    if !isempty(phaseindices)
        return scope.phases[first(phaseindices)]
    else
        return nothing
    end
end

function _getunit(unitname::String, scope::Scope = SCOPE)
    unitindices = findall(unit -> unit.name == unitname, scope.units) 
    if !isempty(unitindices)
        return scope.units[first(unitindices)]
    else
        return nothing
    end
end



struct Simulation
    scope::Scope
    orders::Vector{Order}
    events::EventSystem
    logger::Logger 
end

Simulation(scope::Scope) = Simulation(scope, Vector{Order}[], EventSystem(), Logger())

function placeorder(sim::Simulation, productname::String, quantity::Float64, endtime::Float64)
    push!(sim.orders, Order(productname, quantity, endtime))
end


function run(scope::Scope = SCOPE, logger::Logger = LOGGER; max_cycles::Int64 = 10_000)
    logmessage("Starting run", logger)
    urgentphases = urgent.(scope.phases)
    runcycles = 0
    runcalls = 0
    time = 0.0

    while (Base.:|(urgentphases...)) && (runcycles < max_cycles)
        # needs complete rework and implementation of the event system 
        calledphasesnames = ""
        runcycles += 1
        urgentphases = urgent.(scope.phases)
        for p in scope.phases[urgentphases]
            runcalls += 1
            pf = PhaseFunction(p, 100.0)                    #push!(scope.events, PhaseEndTime(p.name, 5.6))
            time += pf()                                    
            calledphasesnames *= ", $(p.name)"
        end
        println("Cycle $runcycles", calledphasesnames)
    end
    return runcycles, runcalls
end





function run!(sim::Simulation; max_cycles::Int64 = 1000)
    # Initialize
    if length(sim.orders) == 0
        error("Place some orders first. Use the function placeorder to do so.")
    end

    for order in sim.orders
        push!(sim.events, order)
        push!(sim.logger.messages, "there is an order for $(order.quantity) kg of $(order.product.name) due at time $(order.endtime)")
    end

    return sim.logger
end


end # Module PropaneCore