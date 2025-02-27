module Phases

import ..Basetypes: Process, CURRENT_PROCESS
# import ..Events: EventSystem
export Phase, @Phase, CURRENT_PHASE
export @take, @source, @supply
export PhaseFunction

struct Phase
    name::String
    process::Process
    actions::Vector{Expr}
    parameters::Dict{Symbol, Number}
    inputs::Vector{String}
    outputs::Vector{String}
    # supplies::Vector{Stage}            
    # sources::Vector{Stage}                  # _____TODO: Problem with sources and supplies, or source and supply function______
end 

function Phase(name::String="", process::Process=CURRENT_PROCESS)
    return Phase(name, process, Expr[], Dict(), String[], String[])      #, Dict() #, Stage[], Stage[])
end

function (p::Phase)() 
    return eval.(p.actions)
end

# specific_volume(p::Phase) = ifelse(haskey(p.parameters, :volume), p.parameters[:volume], 1.25 *p.parameters[:defaultvolume])


function Base.show(io::IO, p::Phase)
    println(io, "Phasename: ", p.name)
    println(io, "Process: ", p.process.name)
    println(io, "Actions: ", length(p.actions))
    for a in p.actions
        println(io, repeat(" ", 4), a)
    end
    println(io, "Parameters: ")
    for (k, v) in p.parameters
        println(io, repeat(" ", 4), k, " = ", v)
    end
end

global CURRENT_PHASE = Phase()


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

end # module Phases