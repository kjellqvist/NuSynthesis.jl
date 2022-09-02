#function compare(A::Matrix{Float64}, Niter::Int64, θ::Float64)
#    return (nubar_heuristic(A, Niter, θ)[2], nubar_conv(A, optimizationfactory)[2])
#end

#function compare(A::Matrix{Float64}, Niter::Int64, θs::Vector{Float64})
#    c = nubar_conv(A, optimizationfactory)[2]
#    cs = zeros(length(θs), N)
#    for i = 1:length(θs)
#        cs[i, :] = nubar_heuristic(A, Niter, θs[i])[2]
#    end
#    return (cs, c)
#end

"""
    experiments = run_experiments(Na::Int64, Niter::Int64, Nexps::Int64, θs::Vector{Float64}, optimizationfactory)

Computes the costs for randomly generated matrices for the heuristic algorithm and the LP.

Runs `nubar_conv` and `nubar_heuristic` for `Nexps` randomly generate `Na x Na`-matrices.
`nubar_conv` is run for `Niter` iterations for each `θ ∈ θs`.
"""
function run_experiments(Na::Int64, Niter::Int64, Nexps::Int64, θs::Vector{Float64}, optimizationfactory)
    dict = Dict()
    for θ ∈ θs
        dict[θ] = zeros(Nexps, Niter + 1)
    end

    @inbounds for experiment = 1:Nexps
        (experiment % 100 == 0) ? (@info "on " experiment) : nothing
        A = randn(Na, Na);
        cost_conv = nubar_conv(A, optimizationfactory)[2]
        for θ ∈ θs
            dict[θ][experiment, 1] = cost_conv
            dict[θ][experiment, 2:end] = nubar_heuristic(A, Niter, θ)[2]          
        end
    end
    return dict
end

"""
    (ubound, means, stds) = get_statistics(experiment::Matrix{Float64}, tol=1e-8)

Computes the maximum, mean and standard deviation of the relative error of a batch of experiments.

experiment is a matrix where the first column contains the true values of ``\\bar \\nu`` for each experiment.
Column `n + 1` contains the values of the ``n``th iteration of the heuristic algorithm.
The relative error of an estimate ``\\hat \\nu`` of ``\\bar \\nu`` is defined as ``\\hat \\nu / \\bar \\nu + \\text{tol}``.

"""
function get_statistics(experiment::Matrix{Float64}, tol=1e-8)
    normalized = experiment[:, 2:end] ./ experiment[:, 1] .- 1 .+ tol
    ubound = maximum(normalized, dims = 1)[:]
    means = mean(normalized, dims = 1)[:]
    stds = std(normalized, dims=1)[:]
    return (ubound, means, stds)
end


"""
    (data, dstatistics) = gen_data(maxN, Niter, Nexps, θs, optimizationfactory)

Computes the relative tolerance of ``\bar \nu`` for randomly generated matrices using `nubar_heuristic`.

## Example
The results in the article were generated using the following bit of code.
```
using GLPK
maxN = 8                    # Runs experiments for square 2^1n x 2^n matrices, for n = 1:maxN.
Niter = 10000               # Runs nubar_heuristic with 10000 iterations
Nexps = 500                 # Generates 500 random examples per matrix size
θs = Vector(0.2:0.1:.9)     # Runs nubar_heuristic with θ = 0.2, 0.3, ..., 0.9

data, dstatistics = gen_data(maxN, Niter, Nexps, θs, GLPK.Optimizer)
``` 

"""
function gen_data(maxN, Niter, Nexps, θs, optimizationfactory)
    Nas = 2 .^(1:maxN)
    @info "running experiments with" maxN Niter Nexps θs
    data = Dict()
    for Na ∈ Nas
        @info "Starting experiments with" Na
        @time data[Na] = run_experiments(Na, Niter, Nexps, θs, optimizationfactory)
    end
    dstatistics = Dict()
    for Na ∈ Nas
        dstatistics[Na] = Dict()
        for θ ∈ θs
            dstatistics[Na][θ] = get_statistics(data[Na][θ])
        end
    end

    return data, dstatistics
end

"""
    ind = first_until_tol(Na, θ, tol, dstatistics)

Computes the first index for which the worst relative error is smaller than tol.

`dstatistics` is a directory containing statistics. 
The index is returned for the experiment concerning `Na x Na` matrices with `nubar_conv` run with interpolation parameter `θ`.
"""
first_until_tol(Na, θ, tolerance, dstatistics) = (dstatistics[Na][θ][1] .< tolerance) |> findfirst |> (x) -> (x === nothing) ?  Inf : return x
