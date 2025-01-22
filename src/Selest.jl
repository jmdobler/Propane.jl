# Beispiel File für den Selest-Prozess

module PropaneCore

export Phase, @Phase, CURRENT_PHASE, take, @take, Material, Storage, STORAGE, SCOPE, scopesummary

# Todo: Stage
# Todo: Phase Parameter definition, eg volume
# Todo: Phase Quantity normalisation by target amount or only @taking relative wt's and vol's
# Todo: Phase in and out Stages
# Todo: Phase Status: optional, urgent, inactive, processing ...
# Tode: Phase execute()

struct Phase
    name::String
    process::String
    actions::Vector{Expr}
    parameters::Dict{Symbol, Number}
end 

function Phase(name::String, processname::String)
    return Phase(name, processname, Expr[], Dict())
end

function Phase()
    return Phase("", "", Expr[], Dict())
end

function (p::Phase)() 
    return eval.(p.actions)
end

CURRENT_PHASE = Phase()
SCOPE = Vector{Phase}()

macro Phase(phasename)
    global CURRENT_PHASE = Phase(string(phasename), string(__module__))    
    push!(SCOPE, CURRENT_PHASE)
    return CURRENT_PHASE
end

function take(action::Pair{String, Int64})
    mat = getmaterial(action[1])
    if haskey(STORAGE.materials, mat) == false
        STORAGE.materials[mat] = -action[2]
    else
        STORAGE.materials[mat] -= action[2]
    end
end

macro take(material, value)
    push!(CURRENT_PHASE.actions, Expr(:call, take, String(material) => value))
end

macro Phase(phasename, block)
    # is block a begin ... end block?
    if block isa Expr
        if block.head == :block
            # @info dump(block)
            global CURRENT_PHASE = Phase(string(phasename), string(__module__))
            for macroexpr in filter(arg -> !(arg isa LineNumberNode), block.args)
                eval(macroexpr)
            end
            # global CURRENT_PHASE = Phase(String(phasename), eval.(filter(arg -> !(arg isa LineNumberNode), block.args)))
            # @take Meee 123
            push!(SCOPE, CURRENT_PHASE)
            return CURRENT_PHASE
        else
            throw("expression block must be a begin ... end block")
        end
    else
        throw("second argument must be an expression block using begin ... end syntax")
    end
end

struct Material
    number::Int64
    name::String
end

struct Storage
    materials::Dict{Material, Float64}
end

STORAGE = Storage(Dict{Material, Float64}())

function getmaterial(material::String)
    for mat in keys(STORAGE.materials)
        if mat.name == material
            return mat
        end
    end
    return Material(0, material)
end

function scopesummary(scope::Vector{Phase} = SCOPE)
    for phs in scope
        @info phs.name
    end
end

end # Module PropaneCore


module Selest

using ..PropaneCore

@Phase Synthesis
    @take HBL 290
    @take THF 812
    @take Selest 50

@Phase Lithiummethylselenid
    @take THF 1200
    @take Selen 210
    @take Methyllithium 850

@Phase Extraktion begin
    @take DIPE 812
    @take DIPE 810
end

@Phase Me2Me begin
    @take DIPE 812
    @take THF 90
end

@Phase Me2Me
    @take DIPE 812
    @take THF 90

end # Module Selest

using .PropaneCore