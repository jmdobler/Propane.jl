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

include("Core/Scenarios.jl")
using .Scenarios

include("Core/PhaseImplementations.jl")
using .PhaseImplementations

# CURRENT_PHASE = Phase()

include("Core/PropaneMacros.jl")
using .PropaneMacros


export Scope, SCOPE, phases, stages, units, process_summary, scopesummary, within
export Stage, @Stage 
export Unit, @Unit
export Material, Storage, STORAGE, inventory
export Process, @Process, CURRENT_PROCESS, Phase, @Phase, CURRENT_PHASE, take, @take, supply, @supply, source, @source
export Scenario, placeorder!, run, run! 

# Todo: Phase Parameter definition, eg volume
# Todo: Phase Quantity normalisation by target amount or only @taking relative wt's and vol's
# Todo: Add resources and use @implement to assign a ressource to a (Phase or Stage)
# Todo: Scale Phases by either 
# Todo: Phase Status: optional, urgent, inactive / idle, processing ...
# Todo: Log results from run()
# Todo: Access logged results within a dataframe / plot
# Todo: Add time tracking
# Todo: orchestrate Phases based on Status


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





function run!(scenario::Scenario, max_cycles::Int64 = 100)
    if length(scenario.eventlog.events) == 0
        error("Place some orders first. Use the function placeorder to do so.")
    end

    logmessage("Starting run", scenario.eventlog.logs)
    runtime = 0.0	
    runcycles = 0
   
    while length(scenario.eventlog.events) > 0          # || runcycles < max_cycles
        @info runcycles += 1 
        @info length(scenario.eventlog.events)
        event = pop!(scenario.eventlog)
        runtime += event.endtime
        
        if event isa PhaseEndTime
            logdata(runtime, "Phase $(event.phasename) finished", scenario.eventlog.logs)
        elseif event isa Order
            logdata(runtime, "Order for $(event.product.name) complete", scenario.eventlog.logs)
        end
        
        
    end
    return scenario.eventlog.logs
end

end # Module PropaneCore