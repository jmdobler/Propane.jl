# Beispiel File für einen Prozess

module Testprocess

import ..PropaneCore: @Unit, @Stage, @Phase, @take, @source, @supply

# First define the Stages of the process. Stages are intermediate states of the process, where a defined stream is inside a defined unit. 
# Example: 
#   @Unit R01 begin
#       capacity = 1000             # Liters
#       cost = 1.10                 # Euro per hour
#   @Stage HCl_1M begin
#@implement 


#
#   @implement HCl_1M in R01        # As an synthatic idea
#

@Unit R02 1000

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

@Stage Washed_Organic_Phase
@Stage Wastewater

@Phase Workup_Extraction begin
    @source Reaction_Solution 2100
    @take water 200
    @supply Wastewater 250
    @take water 200
    @supply Wastewater 220
    @supply Washed_Organic_Phase 2030
end

@Stage Concentrated_Product_Phase
@Stage Solvent_Destillate

@Phase Workup_Concentrate begin
    @source Washed_Organic_Phase 2030
    @supply Solvent_Destillate 1650
    @supply Concentrated_Product_Phase 380
end

@Stage Crystallized_Suspension

@Phase Crystallization begin
    @source Concentrated_Product_Phase 380
    @take anti_solvent 750
    @supply Crystallized_Suspension 1130
end

@Stage Motherliquor
@Stage Wet_Filter_Cake

@Phase Filtering begin
    @source Crystallized_Suspension 1130
    @supply Wet_Filter_Cake 425
    @supply Motherliquor 705
    @take anti_solvent 100
    @supply Motherliquor 110
end

@Stage Finished_Product isolated

@Phase Drying begin
    @source Wet_Filter_Cake 425
    @supply Finished_Product 312
end

end # Module Testprocess
