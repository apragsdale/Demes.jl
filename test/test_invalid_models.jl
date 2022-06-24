# load and run all valid models in demes-spec

function loadModel(fname::String)
    graph = Demes.loadGraph(fname)
    simplified = Demes.asDictSimplified(graph)
    return simplified
end

@testset "InvalidModels" begin
    for f in readdir(joinpath(@__DIR__, "test-cases/invalid"))
        fname = joinpath(@__DIR__, "test-cases/invalid", f)
        if f in
           ["bad_pulse_time_02.yaml", "bad_pulse_time_04.yaml", "bad_pulse_time_09.yaml"]
            # TODO: finalize pulse time edge cases
            @test_skip loadModel(fname)
        else
            @test_throws Demes.DemesError loadModel(fname)
        end
    end
end
