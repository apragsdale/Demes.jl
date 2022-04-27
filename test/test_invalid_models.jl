# load and run all valid models in demes-spec

function loadModel(fname::String)
    graph = Demes.loadGraph(fname)
    simplified = Demes.asDictSimplified(graph)
    return simplified
end

@testset "InvalidModels" begin
    for f in readdir(joinpath(@__DIR__, "../demes-spec/test-cases/invalid"))
        fname = joinpath(@__DIR__, "../demes-spec/test-cases/invalid", f)
        if occursin("bad_deme_name", f)
            # TODO: figure out how to test for valid deme names
            @test_skip loadModel(fname)
        elseif f in [
            "bad_pulse_time_02.yaml",
            "bad_pulse_time_04.yaml",
            "bad_pulse_time_09.yaml",
        ]
            # TODO: finalize pulse time edge cases
            @test_skip loadModel(fname)
        elseif occursin("bad_migration_rates_sum", f) ||
               occursin("overlapping_migrations", f)
            # TODO: test for overlapping migration issues
            @test_skip loadModel(fname)
        else
            @test_throws Demes.DemesError loadModel(fname)
        end
    end
end
