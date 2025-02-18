module PhaseImplementations

import ..Phases: Phase
import ..EquipmentUnits: Unit
import ..Scenarios: Scenario

struct PhaseImplementation
    phasename::String
    unit::Unit
    phaseactions::Vector{Expr} 
    scalefactor::Float64
    duration::Float64
end

function PhaseImplementation(scenario::Scenario, phase::Phase, unit::Unit, scalefactor::Float64)
    # Check, if unit is available
    
    
    
    # On creation of a PhaseImplementation object, call the supplied actions with the scalefactor
    # Copy the input actions (take and source) with the appropiate scalefactor into the phaseactions vector
    
    
    phaseactions = deepcopy(phase.actions)
    for pa in phaseactions
        push!(pa.args, scalefactor)
    end

    suppliedactions = filter(arg -> arg.head == :call && arg.args[1] == supply, phaseactions)
    inputactions = filter(phaseactions) do phaseaction
        phaseaction.head == :call && phaseaction.args[1] !== supply
    end

    eval.(suppliedactions)
    duration = haskey(phase.parameters, :duration) ? phase.parameters[:duration] : 1.0
    return PhaseFunction(phase.name, inputactions, scalefactor, duration) 
end

function (pf::PhaseImplementation)(scenario::Scenario)
    event = PhaseEndTime(pf.phasename, pf.duration)
    push!(events, event)
    # println(pf.phaseactions)
    eval.(pf.phaseactions)
    return pf.duration
end

end # module PhaseImplementations