using NuSynthesis
using Documenter

DocMeta.setdocmeta!(NuSynthesis, :DocTestSetup, :(using NuSynthesis); recursive=true)

makedocs(;
    modules=[NuSynthesis],
    authors="Olle Kjellqvist",
    repo="https://github.com/kjellqvist/NuSynthesis.jl/blob/{commit}{path}#{line}",
    sitename="NuSynthesis.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://kjellqvist.github.io/NuSynthesis.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/kjellqvist/NuSynthesis.jl",
    devbranch="main",
)
