module Scopes

import ..Stages: Stage
import ..Phases: Phase
import ..EquipmentUnits: Unit
export Scope, SCOPE
export within

struct Scope
    stages::Vector{Stage}     
    phases::Vector{Phase}     
    units::Vector{Unit}
end

function Scope() 
    global SCOPE = Scope(Stage[], Phase[], Unit[])
    return SCOPE
end
# global SCOPE = Scope()

Base.isempty(::Nothing) = true
_register(p::Phase, scope::Scope = SCOPE) = _getphase(p.name, scope) |> isempty ? push!(scope.phases, p) : error("A Phase with the name $(p.name) is already registered.")
_register(s::Stage, scope::Scope = SCOPE) = _getstage(s.name, scope) |> isempty ? push!(scope.stages, s) : error("A Stage with the name $(s.name) is already registered.")
_register(u::Unit,  scope::Scope = SCOPE) = _getunit(u.name, scope)  |> isempty ? push!(scope.units, u)  : error("A Unit with the name $(u.name) is already registered.")  

function Base.show(io::IO, scope::Scope)
    println(io, "Scope with $(length(scope.stages)) Stages:")
    for s in scope.stages
        println(io, repeat(" ", 4), s.name, s.allocation !== 0.0 ? " ($(s.allocation))" : "")
    end
    println(io, "Scope contains $(length(scope.phases)) Phases:")
    for p in scope.phases
        println(io, repeat(" ", 4), p.name)
    end
end

phases(scope::Scope = SCOPE) = scope.phases
stages(scope::Scope = SCOPE) = scope.stages
units(scope::Scope = SCOPE) = scope.units

function within(f::Function, scope::Scope) 
    global SCOPE = scope
    f()
end



end # module Scopes