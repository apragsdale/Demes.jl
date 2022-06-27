@testset "DiscreteEvents" begin
    # test splits
    @test length(
        Demes.getDiscreteDemographicEvents(Demes.loadGraph("data/gutenkunst_ooa.yaml"))["splits"],
    ) == 3
    # TODO: set up isequal functions for Demes structs
    #@test Demes.getDiscreteDemographicEvents(
    #    Demes.loadGraph("gutenkunst_ooa.yaml"),
    #)["splits"][1] == Demes.Split(parent = "ancestral", children = ["AMH"], time = 220000.0)
    #@test Demes.getDiscreteDemographicEvents(
    #    Demes.loadGraph("gutenkunst_ooa.yaml"),
    #)["splits"][2] == Demes.Split(parent = "AMH", children = ["OOA", "YRI"], time = 140000.0)
    #@test Demes.getDiscreteDemographicEvents(
    #    Demes.loadGraph("gutenkunst_ooa.yaml"),
    #)["splits"][3] == Demes.Split(parent = "OOA", children = ["CEU", "CHB"], time = 21200.0)
    # test branches
    # test mergers
    # test admixture
    # test pulses
end
