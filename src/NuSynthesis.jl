module NuSynthesis
    using LinearAlgebra
    using JuMP, Mosek, MosekTools
    #using SparseArrays
    export nubar_heuristic, nubar_conv
    include("methods.jl")
end
