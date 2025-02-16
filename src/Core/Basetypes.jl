module Basetypes

export Material 
export Process, @Process, CURRENT_PROCESS

struct Material
    number::Int64
    name::String
end

struct Process 
    name::String
    yield::Float64
end

global CURRENT_PROCESS = Process("", 0.0)

macro Process(name, yield)
    global CURRENT_PROCESS = Process(string(name), Float64(yield))
    return CURRENT_PROCESS  
end

end # module Basetypes