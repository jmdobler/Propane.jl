
# should I define a Scope variable in Main and pass it around? -- I think so yes!

include("PropaneCore.jl") 
using .PropaneCore

# Set the scope
production_area = Scope() 

# Define what is in the scope
include("Testprocess.jl") 
# include("Testprocess.jl") fails because unitname, stagenames and phasesnames must be unique -- TODO Append the processname for internal use

scenario_2k = Scenario(production_area)
placeorder!(scenario_2k, "Final_Product", 1000.0, due"06.12.2025")
placeorder!(scenario_2k, "Final_Product", 1000.0, due"24.12.2025")


results = PropaneCore.run!(scenario_2k)





duedate1 = due"18.12.2025"
duedate2 = due"14.12.2025"

duedates = [dt for dt in due"01.01.2025":Week(1):due"31.12.2025"]