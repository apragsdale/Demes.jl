using Test
using Demes

@testset "Deme" begin
    # tests that validators are catching bad Deme inputs
    # test bad deme names
    @test_throws ErrorException Demes.validateDemeNameDescription(Dict(), Dict())
    @test_throws ErrorException Demes.validateDemeNameDescription(
        Dict("name" => "A"), Dict("A" => [Inf, 0]))
    @test_throws MethodError Demes.Deme().name = 1
    @test_throws MethodError Demes.Deme().name = Inf
    @test_throws MethodError Demes.Deme().name = ["Hi"]
    @test_throws MethodError Demes.Deme().name = Dict("name" => "X")
    # test bad start time
    @test_throws ErrorException Demes.validateDemeStartTime(
        Dict("start_time" => -1), Dict())
    @test_throws ErrorException Demes.validateDemeStartTime(
        Dict("start_time" => 0), Dict())
    @test_throws ErrorException Demes.validateDemeStartTime(
        Dict("ancestors" => ["A"], "start_time" => 10),
        Dict("A" => [Inf, 20]))
    @test_throws ErrorException Demes.validateDemeStartTime(
        Dict("ancestors" => ["A"], "start_time" => 10),
        Dict("A" => [5, 0]))
    @test_throws ErrorException Demes.validateDemeStartTime(
        Dict("ancestors" => ["A"], "start_time" => 10),
        Dict("A" => [Inf, 10+1e-12]))
    @test_throws ErrorException Demes.validateDemeStartTime(
        Dict("ancestors" => ["A"], "start_time" => 10),
        Dict("A" => [10, 0]))
    @test_throws ErrorException Demes.validateDemeStartTime(
        Dict("ancestors" => ["A", "B"], "start_time" => 10),
        Dict("A" => [Inf, 0], "B" => [Inf, 20]))
    @test_throws ErrorException Demes.validateDemeStartTime(
        Dict("ancestors" => ["A", "B"], "start_time" => 10),
        Dict("A" => [Inf, 0], "B" => [5, 0]))
    @test_throws MethodError Demes.Deme().start_time = "1"
    @test_throws MethodError Demes.Deme().start_time = [1]
    # test bad ancestor proportions
    @test_throws ErrorException Demes.validateDemeAncestorsProportions(
        Dict("ancestors" => ["A", "B"]))
    @test_throws ErrorException Demes.validateDemeAncestorsProportions(
        Dict("ancestors" => ["A", "B"]))
    @test_throws ErrorException Demes.validateDemeAncestorsProportions(
        Dict("ancestors" => ["A", "B"], "proportions" => [1]))
    @test_throws ErrorException Demes.validateDemeAncestorsProportions(
        Dict("ancestors" => ["A", "B"], "proportions" => [0.2, 0.4]))
end

@testset "Migration" begin
    # test bad migration start time
    @test_throws ErrorException Demes.validateMigrationStartTime(
        Dict(), "A", "B", Dict())
    @test_throws ErrorException Demes.validateMigrationStartTime(
        Dict(), "A", "B", Dict("A" => [2, 1]))
    @test_throws ErrorException Demes.validateMigrationStartTime(
        Dict(), "A", "B", Dict("B" => [2, 1]))
    @test_throws ErrorException Demes.validateMigrationStartTime(
        Dict("start_time" => 15), "A", "B", Dict("A" => [10, 0], "B" => [20, 0]))
    @test_throws ErrorException Demes.validateMigrationStartTime(
        Dict("start_time" => 15), "A", "B", Dict("A" => [20, 0], "B" => [10, 0]))
    @test Demes.validateMigrationStartTime(
        Dict(), "A", "B", Dict("A" => [10, 0], "B" => [10, 0])) == 10
    @test Demes.validateMigrationStartTime(
        Dict(), "A", "B", Dict("A" => [5, 0], "B" => [10, 2])) == 5
    @test Demes.validateMigrationStartTime(
        Dict(), "A", "B", Dict("A" => [5, 0], "B" => [1, 0])) == 1
    # test bad migration end time
    @test_throws ErrorException Demes.validateMigrationEndTime(
        Dict(), "A", "B", Dict())
    @test_throws ErrorException Demes.validateMigrationEndTime(
        Dict(), "A", "B", Dict("A" => [2, 1]))
    @test_throws ErrorException Demes.validateMigrationEndTime(
        Dict(), "A", "B", Dict("B" => [2, 1]))
    @test_throws ErrorException Demes.validateMigrationEndTime(
        Dict("end_time" => 2), "A", "B", Dict("A" => [10, 5], "B" => [20, 0]))
    @test_throws ErrorException Demes.validateMigrationEndTime(
        Dict("end_time" => 2), "A", "B", Dict("A" => [20, 0], "B" => [10, 5]))
    @test Demes.validateMigrationEndTime(
        Dict(), "A", "B", Dict("A" => [10, 0], "B" => [10, 0])) == 0
    @test Demes.validateMigrationEndTime(
        Dict(), "A", "B", Dict("A" => [10, 0], "B" => [10, 2])) == 2
    @test Demes.validateMigrationEndTime(
        Dict(), "A", "B", Dict("A" => [10, 3], "B" => [10, 2])) == 3
end

@testset "Pulse" begin
    # test bad pulse fields
    @test_throws ErrorException Demes.validatePulseFields(
        Dict("dest" => "A", "sources" => ["B"], "proportions" => [.1]))
    @test_throws ErrorException Demes.validatePulseFields(
        Dict("time" => 1, "sources" => ["B"], "proportions" => [.1]))
    @test_throws ErrorException Demes.validatePulseFields(
        Dict("time" => 1, "dest" => "A", "proportions" => [.1]))
    @test_throws ErrorException Demes.validatePulseFields(
        Dict("time" => 1, "dest" => "A", "source" => ["B"], "proportions" => [.1]))
    @test_throws ErrorException Demes.validatePulseFields(
        Dict("time" => 1, "dest" => "A", "sources" => ["B"]))
    @test_throws ErrorException Demes.validatePulseFields(
        Dict("time" => 1, "dest" => "A", "sources" => ["B"], "proportion" => [.1]))
    @test_throws ErrorException Demes.validatePulseFields(
        Dict("time" => 1, "dest" => "A", "sources" => "B", "proportions" => [.1]))
    @test_throws ErrorException Demes.validatePulseFields(
        Dict("time" => 1, "dest" => "A", "sources" => ["B"], "proportions" => .1))
    @test_throws ErrorException Demes.validatePulseFields(
        Dict("time" => 1, "dest" => "A", "sources" => ["B", "C"], "proportion" => [.1]))
    @test_throws ErrorException Demes.validatePulseFields(
        Dict("time" => 1, "dest" => "A", "sources" => ["B"], "proportion" => [.1, .2]))
    # test bad pulse demes
    @test_throws ErrorException Demes.validatePulseDemes(
        Dict("time" => 1, "dest" => "A", "sources" => ["A", "B"], "proportion" => [.1, .2]))
    @test_throws ErrorException Demes.validatePulseDemes(
        Dict("time" => 1, "dest" => "A", "sources" => ["B", "B"], "proportion" => [.1, .2])) 
    # test bad pulse time
    @test_throws ErrorException Demes.validatePulseTiming(
        Dict("time" => 10, "sources" => ["A"], "dest" => "B", "proportions" => [0.1]),
        Dict("A" => [Inf, 20], "B" => [Inf, 0]))
    @test_throws ErrorException Demes.validatePulseTiming(
        Dict("time" => 10, "sources" => ["A"], "dest" => "B", "proportions" => [0.1]),
        Dict("A" => [5, 0], "B" => [Inf, 0]))
    @test_throws ErrorException Demes.validatePulseTiming(
        Dict("time" => 10, "sources" => ["A"], "dest" => "B", "proportions" => [0.1]),
        Dict("A" => [Inf, 0], "B" => [Inf, 20]))
    @test_throws ErrorException Demes.validatePulseTiming(
        Dict("time" => 10, "sources" => ["A"], "dest" => "B", "proportions" => [0.1]),
        Dict("A" => [Inf, 0], "B" => [5, 0]))
    # test bad pulse proportions
    @test_throws ErrorException Demes.validatePulseProportions(
        Dict("time" => 10, "sources" => ["A"], "dest" => "B", "proportions" => [-0.5]))
    @test_throws ErrorException Demes.validatePulseProportions(
        Dict("time" => 10, "sources" => ["A"], "dest" => "B", "proportions" => [1.2]))
    @test_throws ErrorException Demes.validatePulseProportions(
        Dict("time" => 10, "sources" => ["A", "B"],
             "dest" => "C", "proportions" => [0.1, -0.5]))
    @test_throws ErrorException Demes.validatePulseProportions(
        Dict("time" => 10, "sources" => ["A", "B"],
             "dest" => "C", "proportions" => [-0.5, 0.1]))
    @test_throws ErrorException Demes.validatePulseProportions(
        Dict("time" => 10, "sources" => ["A", "B"],
             "dest" => "C", "proportions" => [0.6, 0.7]))
end
