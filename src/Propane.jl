
# should I define a Scope variable in Main and pass it around? -- I think so yes!

include("PropaneCore.jl") 
using .PropaneCore

# Set the scope
production_area = Scope() 

# Define what is in the scope
within(production_area) do 
    include("Testprocess.jl")
    #include more processes here
end

# Demands are not part of the scope. They belong to the simulation.
# TODO: Simulation rename in Scenario
# 
sim = Simulation(production_area)
placeorder(sim, "Final_Product", 1000.0, 5.0)
placeorder(sim, "Final_Product", 1000.0, 100.0)

sim


production_area1
    



#using .PropaneCore              # seems like the order matters, using .PropaneCore should be called after SCOPE is ultimately defined. 

@assert Main.SCOPE === PropaneCore.SCOPE

# SCOPE
PropaneCore.SCOPE.stages[end].allocation = -1000 

# SCOPE.stages[1].allocation = -4000 
# STORAGE.materials[Material(1, "C")] = 100


PropaneCore.run!(sim)
# PropaneCore.inventory()
# STORAGE.materials

# length(SCOPE.events)
# SCOPE.phases[1]
# SCOPE

# PropaneCore.urgent.(PropaneCore.SCOPE.phases)
# PropaneCore.SCOPE.phases[end]
