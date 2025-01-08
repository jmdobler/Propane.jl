using Propane
using Test

@testset "Propane.jl" begin
    # Write your tests here.
    @test 1 == 1
    @test mass("C") * 1 + mass("H") * 4 == 16.042
end
