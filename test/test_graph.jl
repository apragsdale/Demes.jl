@testset "Graph" begin
    # test generation time units
    @test_throws Demes.DemesError Demes.buildGraph(Dict())
    @test_throws Demes.DemesError Demes.buildGraph(
        Dict("time_units" => "generations", "generation_time" => 2),
    )
    # test demes are given
    @test_throws Demes.DemesError Demes.buildGraph(Dict("time_units" => "generations"))
    @test_throws Demes.DemesError Demes.buildGraph(
        Dict("time_units" => "generations", "demes" => []),
    )
end
