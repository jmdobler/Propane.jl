module Basetypes

export Material 
export Process, @Process, CURRENT_PROCESS

struct Material
    name::String
    number::Int64
    density::Float64
end

Material(name::String) = Material(name, 0, 1.0)


struct Storage
    materials::Dict{Material, Float64}
end

Base.getindex(storage::Storage, materialname::String) = for mat in keys(storage.materials) if mat.name == materialname return mat end end

STORAGE = Storage(Dict{Material, Float64}())

function inventory(storage::Storage = STORAGE)
    return [(material.name, qunatity) for (material, quantity) in storage.materials if quantity != 0.0]
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