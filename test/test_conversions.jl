function compare_scaling_times(graph)
    gen = graph.generation_time
    scaled_graph = Demes.in_generations(graph)
    for (deme, scaled_deme) in zip(graph.demes, scaled_graph.demes)
        if deme.start_time != scaled_deme.start_time * gen
            throw(error)
        end
        for (epoch, scaled_epoch) in zip(deme.epochs, scaled_deme.epochs)
            if epoch.start_time != scaled_epoch.start_time * gen
                throw(error)
            end
            if epoch.end_time != scaled_epoch.end_time * gen
                throw(error)
            end
        end
    end
    for (mig, scaled_mig) in zip(graph.migrations, scaled_graph.migrations)
        if mig.start_time != scaled_mig.start_time * gen
            throw(error)
        end
        if mig.end_time != scaled_mig.end_time * gen
            throw(error)
        end
    end
    for (pulse, scaled_pulse) in zip(graph.pulses, scaled_graph.pulses)
        if pulse.time != scaled_pulse.time * gen
            throw(error)
        end
    end
    if graph.generation_time != scaled_graph.metadata["generation_time"]
        throw(error)
    end
    return true
end

@testset "Conversions" begin
    graph = Demes.loadGraph(joinpath(@__DIR__, "data/gutenkunst_ooa.yaml"))
    @test compare_scaling_times(graph) == true
    for f in readdir(joinpath(@__DIR__, "examples"))
        if occursin("yaml", f)
            path_name = joinpath(@__DIR__, "examples", f)
            graph = Demes.loadGraph(path_name)
            @test compare_scaling_times(graph) == true
        end
    end
end
