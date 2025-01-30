include("PropaneCore.jl")
using .PropaneCore
include("Testprocess.jl")


PropaneCore.SCOPE.stages[1].allocation = -4000 
PropaneCore.STORAGE.materials[PropaneCore.Material(1, "C")] = 100
PropaneCore.STORAGE

PropaneCore.SCOPE
PropaneCore.urgent(PropaneCore.SCOPE.phases[1])

PropaneCore.run()
PropaneCore.inventory()

PropaneCore.SCOPE
