module NuSynthesis
    using LinearAlgebra
    using JuMP, Mosek, MosekTools
    using Statistics
    using JLD
    using Dates
    export nubar_heuristic, nubar_conv
    export run_experiments, get_statistics, gen_data, first_until_tol
    include("methods.jl")
    include("experiments.jl")
end
