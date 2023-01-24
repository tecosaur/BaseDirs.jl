using XDG
using Documenter

DocMeta.setdocmeta!(XDG, :DocTestSetup, :(using XDG); recursive=true)

makedocs(;
    modules=[XDG],
    authors="TEC <git@tecosaur.net> and contributors",
    repo="https://github.com/tecosaur/XDG.jl/blob/{commit}{path}#{line}",
    sitename="XDG.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://tecosaur.github.io/XDG.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/tecosaur/XDG.jl",
    devbranch="main",
)
