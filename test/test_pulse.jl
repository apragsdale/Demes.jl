@testset "Pulse" begin
    # test bad pulse fields
    @test_throws ErrorException Demes.validatePulseFields(
        Dict("dest" => "A", "sources" => ["B"], "proportions" => [0.1]),
    )
    @test_throws ErrorException Demes.validatePulseFields(
        Dict("time" => 1, "sources" => ["B"], "proportions" => [0.1]),
    )
    @test_throws ErrorException Demes.validatePulseFields(
        Dict("time" => 1, "dest" => "A", "proportions" => [0.1]),
    )
    @test_throws ErrorException Demes.validatePulseFields(
        Dict("time" => 1, "dest" => "A", "source" => ["B"], "proportions" => [0.1]),
    )
    @test_throws ErrorException Demes.validatePulseFields(
        Dict("time" => 1, "dest" => "A", "sources" => ["B"]),
    )
    @test_throws ErrorException Demes.validatePulseFields(
        Dict("time" => 1, "dest" => "A", "sources" => ["B"], "proportion" => [0.1]),
    )
    @test_throws ErrorException Demes.validatePulseFields(
        Dict("time" => 1, "dest" => "A", "sources" => "B", "proportions" => [0.1]),
    )
    @test_throws ErrorException Demes.validatePulseFields(
        Dict("time" => 1, "dest" => "A", "sources" => ["B"], "proportions" => 0.1),
    )
    @test_throws ErrorException Demes.validatePulseFields(
        Dict("time" => 1, "dest" => "A", "sources" => ["B", "C"], "proportion" => [0.1]),
    )
    @test_throws ErrorException Demes.validatePulseFields(
        Dict("time" => 1, "dest" => "A", "sources" => ["B"], "proportion" => [0.1, 0.2]),
    )
    # test bad pulse demes
    @test_throws ErrorException Demes.validatePulseDemes(
        Dict(
            "time" => 1,
            "dest" => "A",
            "sources" => ["A", "B"],
            "proportion" => [0.1, 0.2],
        ),
    )
    @test_throws ErrorException Demes.validatePulseDemes(
        Dict(
            "time" => 1,
            "dest" => "A",
            "sources" => ["B", "B"],
            "proportion" => [0.1, 0.2],
        ),
    )
    # test bad pulse time
    @test_throws ErrorException Demes.validatePulseTiming(
        Dict("time" => 10, "sources" => ["A"], "dest" => "B", "proportions" => [0.1]),
        Dict("A" => [Inf, 20], "B" => [Inf, 0]),
    )
    @test_throws ErrorException Demes.validatePulseTiming(
        Dict("time" => 10, "sources" => ["A"], "dest" => "B", "proportions" => [0.1]),
        Dict("A" => [5, 0], "B" => [Inf, 0]),
    )
    @test_throws ErrorException Demes.validatePulseTiming(
        Dict("time" => 10, "sources" => ["A"], "dest" => "B", "proportions" => [0.1]),
        Dict("A" => [Inf, 0], "B" => [Inf, 20]),
    )
    @test_throws ErrorException Demes.validatePulseTiming(
        Dict("time" => 10, "sources" => ["A"], "dest" => "B", "proportions" => [0.1]),
        Dict("A" => [Inf, 0], "B" => [5, 0]),
    )
    # test bad pulse proportions
    @test_throws ErrorException Demes.validatePulseProportions(
        Dict("time" => 10, "sources" => ["A"], "dest" => "B", "proportions" => [-0.5]),
    )
    @test_throws ErrorException Demes.validatePulseProportions(
        Dict("time" => 10, "sources" => ["A"], "dest" => "B", "proportions" => [1.2]),
    )
    @test_throws ErrorException Demes.validatePulseProportions(
        Dict(
            "time" => 10,
            "sources" => ["A", "B"],
            "dest" => "C",
            "proportions" => [0.1, -0.5],
        ),
    )
    @test_throws ErrorException Demes.validatePulseProportions(
        Dict(
            "time" => 10,
            "sources" => ["A", "B"],
            "dest" => "C",
            "proportions" => [-0.5, 0.1],
        ),
    )
    @test_throws ErrorException Demes.validatePulseProportions(
        Dict(
            "time" => 10,
            "sources" => ["A", "B"],
            "dest" => "C",
            "proportions" => [0.6, 0.7],
        ),
    )
end
