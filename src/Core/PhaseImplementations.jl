module PhaseImplementations

import ..Phases: Phase
import ..EquipmentUnits: Unit
import ..Scenarios: Scenario
import ..Scopes: _getphase

struct PhaseImplementation
    phasename::String
    unit::Unit
    phaseactions::Vector{Expr} 
    scalefactor::Float64
    duration::Float64
end

function PhaseImplementation(scenario::Scenario, phasename::String, unit::Unit, requirement::Float64)
    # requirement in kg

    # Check, if unit is available
    #...
    phase = _getphase(phasename, scenario.scope)
    max_usable_volume = unit.capacity
    max_required_volume = requirement * max_scalefactor(phase)
    scalefactor = max_required_volume / max_usable_volume

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
    return # PhaseImplementation(phase.name, inputactions, scalefactor, duration) 
end

function (pf::PhaseImplementation)(scenario::Scenario)
    event = PhaseEndTime(pf.phasename, pf.duration)
    push!(events, event)
    # println(pf.phaseactions)
    eval.(pf.phaseactions)
    return pf.duration
end

end # module PhaseImplementations