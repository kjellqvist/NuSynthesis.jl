"""
    (ds, costs) = nubar_heuristic(A::Matrix{Float64}, N::Int64, θ::Float64)

Calculates and the balancing weights and the costs using the heuristic Algorithm.

Here, `A` is a square matrix, `N` is the number of iterations and `0 < θ < 1` is the interpolation parameter.
## Example
```
A = [1. 2.; 3. 4.]
(ds, costs) = nubar_heuristic(A, 10, 0.5)

```

"""
function nubar_heuristic(A::Matrix{Float64}, N::Int64, θ::Float64)
    Na = size(A)[1]
    ds = zeros(Na, N)
    ds[:,1] .= 1
    ds[1, :] .= 1
    @inbounds for n = 1:(N-1)
        ds[2:Na, n+1] .= (1 - θ)*ds[2:Na, n] + θ*sqrt.(maximum(abs.(A[1:Na, 2:Na]) .* ds[1:Na, n], dims=1)[:] ./ maximum(abs.(A[2:Na, 1:Na]) ./ ds[1:Na, n]', dims=2))
    end
    return (ds, costs_(A, ds))
end
"""
    (d, γ) = nubar_conv(A::Matrix{Float64}, optimizationfactory)

Computes the weigths and cost for a square matrix A using linear programming.

## Example
```
using Hypatia
A = [1. 2.; 3. 4.]
(d, cost) = nubar_conv(A, Hypatia.Optimizer)

```

"""
function nubar_conv(A::Matrix{Float64}, optimizationfactory)
    n = size(A)[1]
    model = Model(optimizationfactory)
    set_silent(model)
    @variable(model, l[1:n])
    @variable(model, β)
    for i=1:n
        for j=1:n
            if A[i, j] != 0
                @constraint(model, log(abs(A[i,j])) + l[i] - l[j] -β ≤ 0)
            end
        end
    end
    @constraint(model, l[1] .== 0)
    @objective(model, Min, β)
    optimize!(model)
    d = l .|> value .|> exp
    γ = β |> value |> exp
    return (d, γ)
end

function costs_(A::Matrix{Float64}, ds::Matrix{Float64})
    N = size(ds)[2]
    cs = zeros(N)
    for n = 1:N
        cs[n] =  ds[:, n] .* abs.(A) ./ ds[:, n]' |> maximum
    end
    return cs
end
