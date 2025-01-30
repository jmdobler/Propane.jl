# Beispiel File für einen Prozess

module Testprocess

using ..PropaneCore

# First define the Stages of the process. Stages are intermediate states of the process, where a defined stream is inside a defined unit. 
# Example: 
#   @Unit R01 begin
#       capacity = 1000             # Liters
#       cost = 1.10                 # Euro per hour
#   @Stage HCl_1M begin
# 

@Unit R01 1000

@Stage Reaction_Solution 
@Stage WaterPhase

@Phase Synthesis begin
    @take keyraw 300                # all amounts in kg
    @take solvent 1802
    @take water 560
    @take reagent 90.5
    @take catalyst 5.5
    @supply Reaction_Solution 2100  # Maybe allow (solvent, keyraw, catalyst) => calculate based on amount and density
    @supply WaterPhase 650          # Liters that is
    # @supply Destillate 800        # FAILS, because Destillate is defined later in the file. Maybe allow forward definition of Stages within Phase blocks.
end

@Stage Destillate

end # Module Testprocess
