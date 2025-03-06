module Scenarios

import Dates: DateTime
import ..Events: EventSystem, Order
import ..Scopes: Scope
import ..Units: Unit
export Scenario, placeorder!

struct Scenario
    scope::Scope
    available_units::Set{Unit}
    eventlog::EventSystem
end

Scenario(scope::Scope) = Scenario(scope, Set{Unit}(), EventSystem())

placeorder!(scenario::Scenario, productname::String, quantity::Float64, endtime::DateTime) = push!(scenario.eventlog, Order(productname, quantity, endtime))
placeorder!(scenario::Scenario, produtname::String, quantitiy::Float64, endtimes::Vector{DateTime}) = [placeorder!(scenario, produtname, quantitiy, endtime) for endtime in endtimes]

end # module Scenarios