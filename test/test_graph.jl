@testset "Graph" begin
    # test generation time units
    @test_throws ErrorException Demes.buildGraph(Dict())
    @test_throws ErrorException Demes.buildGraph(
        Dict("time_units" => "generations", "generation_time" => 2),
    )
    # test demes are given
    @test_throws ErrorException Demes.buildGraph(Dict("time_units" => "generations"))
    # demes with multiple ancestors have start time
    @test_throws ErrorException Demes.buildGraph(
        Dict("time_units" => "generations", "demes" => [Dict("ancestors" => ["A", "B"])]),
    )
end
