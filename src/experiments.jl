function compare(A::Matrix{Float64}, Niter::Int64, θ::Float64)
    return (nubar_heuristic(A, Niter, θ)[2], nubar_conv(A)[2])
end

function compare(A::Matrix{Float64}, Niter::Int64, θs::Vector{Float64})
    c = nubar_conv(A)[2]
    cs = zeros(length(θs), N)
    for i = 1:length(θs)
        cs[i, :] = nubar_heuristic(A, Niter, θs[i])[2]
    end
    return (cs, c)
end

function run_experiments(Na::Int64, Niter::Int64, Nexps::Int64, θs::Vector{Float64})
    dict = Dict()
    for θ ∈ θs
        dict[θ] = zeros(Nexps, Niter + 1)
    end

    @inbounds for experiment = 1:Nexps
        (experiment % 100 == 0) ? (@info "on " experiment) : nothing
        A = randn(Na, Na);
        cost_conv = nubar_conv(A)[2]
        for θ ∈ θs
            dict[θ][experiment, 1] = cost_conv
            dict[θ][experiment, 2:end] = nubar_heuristic(A, Niter, θ)[2]          
        end
    end
    return dict
end


function get_statistics(experiment::Matrix{Float64})
    normalized = experiment[:, 2:end] ./ experiment[:, 1] .- 1 .+ 1e-8
    ubound = maximum(normalized, dims = 1)[:]
    means = mean(normalized, dims = 1)[:]
    stds = std(normalized, dims=1)[:]
    return (ubound, means, stds)
end

function gen_data(maxN, Niter, Nexps, θs)
    Nas = 2 .^(1:maxN)
    @info "running experiments with" maxN Niter Nexps θs
    dd = Dict()
    for Na ∈ Nas
        @info "Starting experiments with" Na
        @time dd[Na] = run_experiments(Na, Niter, Nexps, θs)
    end
    dstatistics = Dict()
    for Na ∈ Nas
        dstatistics[Na] = Dict()
        for θ ∈ θs
            dstatistics[Na][θ] = get_statistics(dd[Na][θ])
        end
    end

    return dd, dstatistics
end

first_until_tol(Na, θ, tolerance, dstatistics) = (dstatistics[Na][θ][1] .< tolerance) |> findfirst |> (x) -> (x === nothing) ?  Inf : return x
