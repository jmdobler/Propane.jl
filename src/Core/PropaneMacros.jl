module PropaneMacros

import Dates: DateTime, DateFormat
import ..Basetypes: Material, Process, CURRENT_PROCESS
import ..EquipmentUnits: Unit
import ..Stages: Stage
import ..Phases: Phase, take, source, supply
import ..Scopes

export @Unit, @Stage, @Phase, @take, @source, @supply, @implement, @due_str

const kg = 1
const g = 1e-3kg
const t = 1e3kg
const h = 1
const min = 60h

macro Unit(name, capacity)
    if capacity isa Expr && capacity.head == :block
        return capacity
    else
    u = Unit(String(name), Float64(capacity))
    Scopes._register(u)
    return u
    end
end

macro Stage(name, isolate = false)
    isolate !== false && isolate == Symbol("isolated") ? is_isolated = true : is_isolated = false
    s = Stage(string(name); isolated = is_isolated)
    Scopes._register(s)
    return s
end

macro take(material, value)
    push!(CURRENT_PHASE.actions, Expr(:call, take, String(material) => Float64(value)))
end

macro source(stagename, value)
    push!(CURRENT_PHASE.inputs, String(stagename))
    push!(CURRENT_PHASE.actions, Expr(:call, source, String(stagename) => Float64(value)))
end

macro supply(stagename, value)
    push!(CURRENT_PHASE.outputs, String(stagename))
    #ifelse(haskey(CURRENT_PHASE.parameters, :defaultvolume), CURRENT_PHASE.parameters[:defaultvolume] += Float64(value), CURRENT_PHASE.parameters[:defaultvolume] = Float64(value))
    if haskey(CURRENT_PHASE.parameters, :defaultvolume)
        CURRENT_PHASE.parameters[:defaultvolume] += Float64(value)
    else
        CURRENT_PHASE.parameters[:defaultvolume] = Float64(value)
    end
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
            Scopes._register(CURRENT_PHASE)
            return CURRENT_PHASE
        else
            throw("Expression block must be a begin ... end block")
        end
    else
        throw("Second argument must be an expression block using begin ... end syntax")
    end
end

macro implement(phase_in_unit)
    if phase_in_unit isa Expr
        if phase_in_unit.head == :call
            if phase_in_unit.args[1] == :in
                # return Expr(:call, Expr(:call, :implement, String(phase_in_unit.args[2]), CURRENT_UNIT))
                p = Scopes._getphase(String(phase_in_unit.args[2]))
                u = Scopes._getunit(String(phase_in_unit.args[3]))
                Scopes.SCOPE.implementations[p] = u
                return (p, u) #dump(phase_in_unit)
            else
                throw("Error in expression $phase_in_unit")
            end
        else
            throw("Error in expression $phase_in_unit")
        end        
    else
        throw("Error in expression $phase_in_unit")
    end
end

macro due_str(date)
    return DateTime(date, DateFormat("d.m.y"))
end


end # module PropaneMacros