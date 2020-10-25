using HDF5Arrays
using Documenter

makedocs(;
    modules=[HDF5Arrays],
    authors="Paul Nemec",
    repo="https://github.com/Luapulu/HDF5Arrays.jl/blob/{commit}{path}#L{line}",
    sitename="HDF5Arrays.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://Luapulu.github.io/HDF5Arrays.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/Luapulu/HDF5Arrays.jl",
)
