# Beispiel File für einen Prozess

#module Testprocess

#import ..PropaneCore: @Process, @Unit, @Stage, @Phase, @take, @source, @supply

# Used equipment for the process implementation with maximum filling volume in liters
@Unit R01 700
@Unit R02 1000

@Process Final_Product 312          # yield in kg

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
    duration = 160.0                  # hours
    volume = 2750.0                   # liters
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

@Phase Filtration begin
    @source Crystallized_Suspension 1130
    @supply Wet_Filter_Cake 425
    @supply Motherliquor 705
    @take anti_solvent 100
    @supply Motherliquor 110
end

@Stage Final_Product isolated

@Phase Drying begin
    @take Nitrogen 102
    @source Wet_Filter_Cake 425
    @supply Final_Product 312
    duration = 18
    volume = 300
end

#end # Module Testprocess
