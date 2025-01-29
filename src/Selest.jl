# Beispiel File für den Selest-Prozess

module Selest

using ..PropaneCore

@Phase Synthesis
    @take HBL 290
    @take THF 812
    @take Selest 50

@Phase Lithiummethylselenid
    @take THF 1200
    @take Selen 210
    @take Methyllithium 850

@Phase Extraktion begin
    @take DIPE 812
    @take DIPE 810
end


@Stage Destillate

@Phase Me2Me begin
    @take DIPE 812
    @take THF 90
    # @source Lithiummethylselenid 50
    # @supply Selest 150
    @supply Destillate 855
end

@Stage OrganischerAbfall isolated

@Phase Entsorgung begin
    @source Destillate 100
    @supply OrganischerAbfall 100
end

end # Module Selest
