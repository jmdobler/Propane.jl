include("PropaneCore.jl")
using .PropaneCore

include("Selest.jl")

SCOPE.stages[1].allocation = -1000
PropaneCore.run()
