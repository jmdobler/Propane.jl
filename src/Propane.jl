module Propane

include("Methane.jl")
using .Carbon

mass("C") * 1 + mass("H") * 4
mass("C") * 3 + mass("H") * 8

end
