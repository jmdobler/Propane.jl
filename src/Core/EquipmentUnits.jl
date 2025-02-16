module EquipmentUnits

export Unit, @Unit

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
    Scopes._register(u)
    return u
    end
end

end # module EquipmentUnits