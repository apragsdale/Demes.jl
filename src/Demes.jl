# __precompile__(true)

# module Demes

include("demes_structs.jl")
include("loader.jl") # read YAML formatted models as data
# include("writer.jl") # write models to YAML format
# include("simplifier.jl") # simplify a model to non-redundant
include("utils.jl") # functions to manipulate and get information from model
