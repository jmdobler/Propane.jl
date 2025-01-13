# Beispiel File für den Selest-Prozess

Phase("Lithiummethylselenid", begin
    @take THF 1200
    @take Selen 290
    @take Methyllithium 850
#    @duration 38
#    @result MeSeLi 
end)

struct Phase
    name::String
    actions::Vector{Expr}
end 

# p = Phase("Lithiummethylselenid", "methyllithium" => 80)

# p = Phase("Lithiummethylselenid", Dict{String, Int}())
# a = "methyllithium" => 80

# macroexpand(@Phase "Lithiummethylselenid" begin
#     @take THF 1200
#     @take Selen 290
#     @take Methyllithium 850
#     # @duration 38
#     # @result MeSeLi 
# end)

function take(action::Pair{String, Int64})
    return action
end

macro take(material, value)
    return Expr(:call, take, String(material) => value)
end

