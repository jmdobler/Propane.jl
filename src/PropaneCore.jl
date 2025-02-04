module PropaneCore

import DataStructures: BinaryMinMaxHeap

export Scope, SCOPE, phases, stages, units, process_summary, scopesummary
export Stage, @Stage 
export Unit, @Unit
export Material, Storage, STORAGE, inventory
export Phase, @Phase, CURRENT_PHASE, take, @take, supply, @supply, source, @source
export run 

# Todo: Phase Parameter definition, eg volume
# Todo: Phase Quantity normalisation by target amount or only @taking relative wt's and vol's
# Todo: Add resources and use @implement to assign a ressource to a (Phase or Stage)
# Todo: Scale Phases by either 
# Todo: Phase Status: optional, urgent, inactive / idle, processing ...
# Todo: Log results from run()
# Todo: Access logged results within a dataframe / plot
# Todo: Add time tracking
# Todo: orchestrate Phases based on Status

struct PhaseEndTime
    phasename::String
    endtime::Float64
end

Base.isless(x::PhaseEndTime, y::PhaseEndTime) = x.endtime < y.endtime

RunningPhases = BinaryMinMaxHeap{PhaseEndTime}
x = RunningPhases([PhaseEndTime("A", 5.0), PhaseEndTime("B", 2.0), PhaseEndTime("C", 3.0)])


struct Unit
    name::String
    capacity::Float64
    # cost::Float64
end

macro Unit(name, capacity)
    if capacity isa Expr && capacity.head == :block
        return capacity
    else
    u = Unit(String(name), Float64(capacity))
    _register(u)
    return u
    end
end



mutable struct Stage
    name::String
    process::String
    allocation::Float64 #   Positive value = surplus that needs to be spent eventually, negative values = demand, which needs to be balanced urgently
                        # a Stage with a demand (ie a negative allocation) is a sink, with a surplus (positive allocation) is a source
                        # a Phase that supplys a Stage with a demand is urgent 
                        # a Phase that sources a Stage with a surplus is optional 
                        # otherwise a Phase is inactive 
    isolated::Bool      #   An isolated Stage can be send to the storage for later use
                        # there should be a separate Phase that supplies the storage (say, a wet intermediate can be isolated or further dried and then isolated)
end

function Stage(name::String, process::String; allocation::Float64 = 0.0, isolated::Bool = false)
     return Stage(name, process, allocation, isolated)
end

macro Stage(name, isolate = false)
    isolate !== false && isolate == Symbol("isolated") ? is_isolated = true : is_isolated = false
    s = Stage(string(name), string(__module__); isolated = is_isolated)
    _register(s)
    return s
end



struct Phase
    name::String
    process::String
    actions::Vector{Expr}
    parameters::Dict{Symbol, Number}
    supplies::Vector{Stage}            # Vector{Stage}
    sources::Vector{Stage}             # Vector{Stage} use findall-function to link
end 

function Phase(name::String, processname::String)
    return Phase(name, processname, Expr[], Dict(), Stage[], Stage[])
end

function Phase()
    return Phase("", "", Expr[], Dict(), Stage[], Stage[])
end

function (p::Phase)() 
    return eval.(p.actions)
end

function (p::Phase)[]()
    println("Executing Phase $(p.name)")
    return eval.(p.actions)
end

CURRENT_PHASE = Phase()

macro Phase(phasename)
    global CURRENT_PHASE = Phase(string(phasename), string(__module__))    
    _register(CURRENT_PHASE)
    return CURRENT_PHASE
end


struct Scope
    stages::Vector{Stage}     
    phases::Vector{Phase}     
    units::Vector{Unit}
    running_phases::BinaryMinMaxHeap{PhaseEndTime}
end

Scope() = Scope(Stage[], Phase[], Unit[], BinaryMinMaxHeap{PhaseEndTime}())
global SCOPE = Scope()

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


function urgent(phase::Phase)
    return minimum([suppliedstage.allocation for suppliedstage in phase.supplies]) < 0
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

struct Material
    number::Int64
    name::String
end

struct Storage
    materials::Dict{Material, Float64}
end

STORAGE = Storage(Dict{Material, Float64}())
Base.getindex(storage::Storage, materialname::String) = for mat in keys(storage.materials) if mat.name == materialname return mat end end

# function getmaterial(material::String)
#     for mat in keys(STORAGE.materials)
#         if mat.name == material
#             return mat
#         end
#     end
#     return Material(0, material)
# end

function inventory(storage::Storage = STORAGE)
    return [(key.name, value) for (key, value) in storage.materials if value != 0.0]
end


function take(action::Pair{String, Float64})
    mat = STORAGE[action[1]]
    if mat !== nothing
        STORAGE.materials[mat] -= action[2]
    else
        STORAGE.materials[Material(0, action[1])] = -action[2]
    end
end

macro take(material, value)
    push!(CURRENT_PHASE.actions, Expr(:call, take, String(material) => Float64(value)))
end

macro Phase(phasename, block, kwargs...)

    # set parameters
    for arg in keys(NamedTuple(kwargs))
        CURRENT_PHASE.parameters[arg] = kwargs[arg]
    end

    # is block a begin ... end block?
    if block isa Expr
        if block.head == :block
            # @info dump(block)
            global CURRENT_PHASE = Phase(string(phasename), string(__module__))
            for macroexpr in filter(arg -> !(arg isa LineNumberNode), block.args) 
                eval(macroexpr)
            end
            # global CURRENT_PHASE = Phase(String(phasename), eval.(filter(arg -> !(arg isa LineNumberNode), block.args)))
            _register(CURRENT_PHASE)
            return CURRENT_PHASE
        else
            throw("expression block must be a begin ... end block")
        end
    else
        throw("second argument must be an expression block using begin ... end syntax")
    end
end




function scopesummary(scope::Scope)
    for ps in scope
        @info ps.key ps.value name
    end
end


function supply(action::Pair{Stage, Float64})
    # stage = action[1]
    # added amount = action[2]
    action[1].allocation += action[2]
end

macro supply(stagename, value)
    local stage = _getstage(String(stagename))
    push!(CURRENT_PHASE.actions, Expr(:call, supply, stage => Float64(value)))
    push!(CURRENT_PHASE.supplies, stage)
end



function source(action::Pair{Stage, Float64})
    action[1].allocation -= action[2]
end

macro source(stagename, value)
    local stage = _getstage(String(stagename))
    push!(CURRENT_PHASE.actions, Expr(:call, source, stage => Float64(value)))
    push!(CURRENT_PHASE.sources, stage)
end

function _getstage(stagename::String, scope::Scope = SCOPE)
    stageindices = findall(stage -> stage.name == stagename, scope.stages)
    if !isempty(stageindices)
        return scope.stages[first(stageindices)]
    else
        return []
    end
end

function _getphase(phasename::String, scope::Scope = SCOPE)
    phaseindices = findall(phase -> phase.name == phasename, scope.phases) 
    if !isempty(phaseindices)
        return scope.phases[first(phaseindices)]
    else
        return []
    end
end

function _getunit(unitname::String, scope::Scope = SCOPE)
    unitindices = findall(unit -> unit.name == unitname, scope.units) 
    if !isempty(unitindices)
        return scope.units[first(unitindices)]
    else
        return []
    end
end

function run(scope::Scope = SCOPE)
    urgentphases = urgent.(scope.phases)
    runcycles = 0
    runcalls = 0
    while Base.:|(urgentphases...)
        calledphasesnames = ""
        runcycles += 1
        urgentphases = urgent.(scope.phases)
        for p in scope.phases[urgentphases]
            runcalls += 1
            push!(scope.running_phases, PhaseEndTime(p.name, 5.6))
            p()
            calledphasesnames *= ", $(p.name)"
        end
        println("Cycle $runcycles", calledphasesnames)
    end
    return runcycles, runcalls
end

end # Module PropaneCore