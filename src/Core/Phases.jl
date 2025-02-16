module Phases

import ..Basetypes: Process, CURRENT_PROCESS
import ..Events: EventSystem
export Phase, @Phase, CURRENT_PHASE
export @take, @source, @supply
export PhaseFunction

const kg = 1
const g = 1e-3kg
const t = 1e3kg
const h = 1
const min = 60h


struct Phase
    name::String
    process::Process
    actions::Vector{Expr}
    # interactions::Dict{Symbol, Number}        # inputs and outputs, used to store normalized @take, @source and @supply amounts
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

macro take(material, value)
    push!(CURRENT_PHASE.actions, Expr(:call, take, String(material) => Float64(value)))
end

macro source(stagename, value)
    push!(CURRENT_PHASE.inputs, String(stagename))
    push!(CURRENT_PHASE.actions, Expr(:call, source, String(stagename) => Float64(value)))
end

macro supply(stagename, value)
    push!(CURRENT_PHASE.outputs, String(stagename))
    push!(CURRENT_PHASE.actions, Expr(:call, supply, String(stagename) => Float64(value)))
end

macro Phase(phasename, block)
    if block isa Expr
        if block.head == :block
            # Handle sequence of statements within the begin...end block that are provided by the process descriptions
            # Macros are used to indicate actions, such as take, source, supply
            # Assignment synthax is used to set parameters in the Phase object

            # Create a new Phase and assign the global variable CURRENT_PHASE to it
            global CURRENT_PHASE = Phase(string(phasename), CURRENT_PROCESS)

            # iterate over all expressions in the block
            for exprn in filter(arg -> !(arg isa LineNumberNode), block.args) 
                
                # An action is indicated by a macrocall in the universal form: @action object amount
                # The object must parse as a string, and the amount must be a numberical value
                # The amount is normalized to the yield of the process and the macrocall is evaluated
                # The called actionmacros will 
                if exprn.head == :macrocall
                    exprn.args[4] = eval(exprn.args[4]) / CURRENT_PROCESS.yield
                    eval(exprn)

                # A Parameter is indicated by an assignment in the universal form: parameter_name = value
                # Defined parameters are store in a dictonary in the Phase object. 
                # While most of the passed parameters arn't further processed, the volume is an exception. The volume is normalized to the yield of the process.
                elseif exprn.head == :(=)
                    if exprn.args[1] == :volume
                        exprn.args[2] = eval(exprn.args[2]) / CURRENT_PROCESS.yield
                    end
                    CURRENT_PHASE.parameters[Symbol(exprn.args[1])] = exprn.args[2]
                
                # Only action and parameter definitions are necessary in the block statement. Other expressions will error.
                else
                    throw("Error in expression $exprn")
                end
            end

            # Once actions and parameters are set, the Phase object is registered in the global scope (SCOPE variable)
            _register(CURRENT_PHASE)
            return CURRENT_PHASE
        else
            throw("Expression block must be a begin ... end block")
        end
    else
        throw("Second argument must be an expression block using begin ... end syntax")
    end
end


struct PhaseFunction 
    phasename::String
    phaseactions::Vector{Expr} 
    scalefactor::Float64
    duration::Float64
end

function PhaseFunction(phase::Phase, scalefactor::Float64)
    # On creation of a PhaseFunction object, call the supplied actions with the scalefactor
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

function (pf::PhaseFunction)(events::EventSystem)
    event = PhaseEndTime(pf.phasename, pf.duration)
    push!(events, event)
    # println(pf.phaseactions)
    eval.(pf.phaseactions)
    return pf.duration
end



end # module Phases