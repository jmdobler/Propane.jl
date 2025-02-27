module Scopes

import ..Stages: Stage
import ..Phases: Phase
import ..EquipmentUnits: Unit
export Scope, SCOPE
export within, max_scalefactor

struct Scope
    stages::Vector{Stage}     
    phases::Vector{Phase}     
    units::Vector{Unit}
    implementations::Dict{Phase, Unit}
end

function Scope() 
    global SCOPE = Scope(Stage[], Phase[], Unit[], Dict{Phase, Unit}())
    return SCOPE
end
# global SCOPE = Scope()

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


Base.isempty(::Nothing) = true
_register(p::Phase, scope::Scope = SCOPE) = _getphase(p.name, scope) === nothing ? push!(scope.phases, p) : error("A Phase with the name $(p.name) is already registered.")
_register(s::Stage, scope::Scope = SCOPE) = _getstage(s.name, scope) === nothing ? push!(scope.stages, s) : error("A Stage with the name $(s.name) is already registered.")
_register(u::Unit,  scope::Scope = SCOPE) = _getunit(u.name, scope)  === nothing ? push!(scope.units, u)  : error("A Unit with the name $(u.name) is already registered.")  

function Base.show(io::IO, scope::Scope)
    println(io, "Scope with $(length(scope.stages)) Stages:")
    for s in scope.stages
        println(io, repeat(" ", 4), s.name, s.allocation !== 0.0 ? " ($(s.allocation))" : "")
    end
    println(io, "Scope contains $(length(scope.phases)) Phases:")
    for p in scope.phases
        println(io, repeat(" ", 4), p.name)
    end
    println(io, "Scope with $(length(scope.units)) Units:")
    for u in scope.units
        println(io, repeat(" ", 4), u.name)
    end 
end

phases(scope::Scope = SCOPE) = scope.phases
stages(scope::Scope = SCOPE) = scope.stages
units(scope::Scope = SCOPE) = scope.units


function max_scalefactor(p::Phase, impl::Dict{Phase, Unit} = SCOPE.implementations) 
    if haskey(p.parameters, :volume)
        vol = p.parameters[:volume]
    else
        vol = 1.25 * p.parameters[:defaultvolume]
    end

    if haskey(impl, p)
        capacity = impl[p].capacity
    else
        capacity = NaN
    end

    return capacity / vol 
end

end # module Scopes