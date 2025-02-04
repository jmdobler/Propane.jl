
# should I define a Scope variable in Main and pass it around?

include("PropaneCore.jl")
include("Testprocess.jl")
using .PropaneCore              # seems like the order matters, using .PropaneCore should be called after SCOPE is ultimately defined. 

@assert Main.SCOPE === PropaneCore.SCOPE

# SCOPE
SCOPE.stages[end].allocation = -10_000 

# SCOPE.stages[1].allocation = -4000 
# STORAGE.materials[Material(1, "C")] = 100


PropaneCore.run()
# PropaneCore.inventory()
# STORAGE.materials

length(SCOPE.running_phases)
SCOPE.phases[4]
