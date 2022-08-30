@info "Loading packages"
using Pkg
Pkg.activate(".")
using NuSynthesis
using Statistics
using Plots
using JLD
using Dates
Plots.scalefontsizes(2)
#using Test

#@testset "NuSynthesis.jl" begin
    # Write your tests here.
#end

#timeheur(A::Matrix{Float64}, N::Int64, θ::Float64) = @time nubar_heuristic(A, N, θ)
#timeconv(A::Matrix{Float64}) = @time nubar_conv(A)

#Na = 100
#N = 100
#θ = 0.5
#A = randn(Na, Na)
#(ds, cs) = timeheur(A, N, θ)
#(d, c) = timeconv(A)

##
#Nas = 2 .^(1:6)
#Niter = 100
#Nexps = 100
#θs = Vector(0.2:0.2:1)


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


#@time d = run_experiments(Na, Niter, Nexps, θs)
#headers = ["optimal";1:Niter]

#df1 = DataFrame(d[1], ["Optimal"; string.(1:N)])
##

##
#normalized1 = d[.6][:, 2:end]./d[1][:, 1] .-1 .+ 1e-8
#plot(normalized1', label = false, linecolor = :blue, alpha = 0.1, yaxis = :log)
## iterations until epsilon
maxN = 3
Nas = 2 .^(1:maxN)
Niter = 10
Nexps = 10
θs = Vector(0.2:0.1:.9)

@info "running experiments with" maxN Niter Nexps θs

dd = Dict()
for Na ∈ Nas
    @info "Starting experiments with" Na
    dd[Na] = run_experiments(Na, Niter, Nexps, θs)
end

dstatistics = Dict()
for Na ∈ Nas
    dstatistics[Na] = Dict()
    for θ ∈ θs
        dstatistics[Na][θ] = get_statistics(dd[Na][θ])
    end
end

save(string(now())*".jld", "dd", dd, "dstatistics", dstatistics)

first_until_tol(Na, θ, tolerance) = (dstatistics[Na][θ][1] .< tolerance) |> findfirst |> (x) -> (x === nothing) ?  Inf : return x


tolerance = 1e-3
@info "tolerance for plot set to" tolerance


##
p = plot( yaxis = "N", legend = :bottomright, color_palette = palette(:Blues_9), size = (600, 400))
for θ ∈ θs[1:end-2]
    plot!(p, Nas, (Na) -> first_until_tol(Na, θ, tolerance), 
    label = false, xaxis = "Na", linewidth = 2, marker = :x, markersize = 5, ylims = (0, 850))
end

savefig(p, "fix_tol_e-3.png")

## Fix Na, vary epsilon
Na = 2^2
p = plot(yaxis = "N", xaxis = "tolerance", color_palette = palette(:Blues_9), size = (600, 400))
plot!(xaxis = :log, xflip = true, legend = :topleft)

for θ ∈ θs[1:end-2]
    plot!(p, 10 .^(0 .- (0:0.01:4)), (tolerance) -> first_until_tol(Na, θ, tolerance), 
    label = false,  linewidth = 2, ylims = (0, Niter))
end
p
savefig(p, "fix_Na_128.png")

Na = 2^8
p = plot(yaxis = "N", xaxis = "tolerance", color_palette = palette(:Blues_9), size = (600, 400))
plot!(xaxis = :log, xflip = true, legend = :topleft)

for θ ∈ θs[1:end-2]
    plot!(p, 10 .^(0 .- (0:0.01:4)), (tolerance) -> first_until_tol(Na, θ, tolerance), 
    label = false,  linewidth = 2, ylims = (0, Niter))
end
p
savefig(p, "fix_Na_256.png")

#Na = 2^9
#p = plot(yaxis = "N", xaxis = "tolerance", color_palette = palette(:Blues_9), size = (600, 400))
#plot!(xaxis = :log, xflip = true, legend = :topleft)

#for θ ∈ θs[1:end-2]
#    plot!(p, 10 .^(0 .- (0:0.01:4)), (tolerance) -> first_until_tol(Na, θ, tolerance), 
#    label = false,  linewidth = 2, ylims = (0, Niter))
#end
#p
#savefig(p, "fix_Na_512.png")
