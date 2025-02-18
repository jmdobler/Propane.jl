
# should I define a Scope variable in Main and pass it around? -- I think so yes!

include("PropaneCore.jl") 
using .PropaneCore

# Set the scope
production_area = Scope() 

# Define what is in the scope
include("Testprocess.jl") 
# include("Testprocess.jl")
#include more processes here

# Demands are not part of the scope. They belong to the simulation.
# TODO: Simulation rename in Scenario
# 
scenario_2k = Scenario(production_area)
placeorder!(scenario_2k, "Final_Product", 1000.0, 5.0)
placeorder!(scenario_2k, "Final_Product", 1000.0, 100.0)


run!(scenario_2k)
