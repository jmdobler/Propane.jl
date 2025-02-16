module Stages

import  ..Basetypes: Process, CURRENT_PROCESS
export Stage, @Stage


mutable struct Stage
    name::String
    process::Process
    allocation::Float64 #   Positive value = surplus that needs to be spent eventually, negative values = demand, which needs to be balanced urgently
                        # a Stage with a demand (ie a negative allocation) is a sink, with a surplus (positive allocation) is a source
                        # a Phase that supplys a Stage with a demand is urgent 
                        # a Phase that sources a Stage with a surplus is optional 
                        # otherwise a Phase is inactive 
    isolated::Bool      #   An isolated Stage can be send to the storage for later use
                        # there should be a separate Phase that supplies the storage (say, a wet intermediate can be isolated or further dried and then isolated)
end

function Stage(name::String, process::Process=CURRENT_PROCESS; allocation::Float64 = 0.0, isolated::Bool = false)
    return Stage(name, process, allocation, isolated)
end

macro Stage(name, isolate = false)
    isolate !== false && isolate == Symbol("isolated") ? is_isolated = true : is_isolated = false
    s = Stage(string(name); isolated = is_isolated)
    _register(s)
    return s
end


end # module Stages