module Scenarios

import ..Events: EventSystem, Order
import ..Scopes: Scope
export Scenario, placeorder!

struct Scenario
    scope::Scope
    eventlog::EventSystem
end

Scenario(scope::Scope) = Scenario(scope, EventSystem())

placeorder!(scenario::Scenario, productname::String, quantity::Float64, endtime::Float64) = push!(scenario.eventlog, Order(productname, quantity, endtime))

end # module Scenarios