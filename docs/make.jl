using XDG
using Documenter
using Org

orgfiles = filter(f -> endswith(f, ".org"),
                  readdir(joinpath(@__DIR__, "src"), join=true))

for orgfile in orgfiles
    mdfile = replace(orgfile, r"\.org$" => ".md")
    read(orgfile, String) |>
        c -> Org.parse(OrgDoc, c) |>
        o -> sprint(markdown, o) |>
        s -> replace(s, r"\.org]" => ".md]") |>
        m -> write(mdfile, m)
end

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
        "Introduction" => "index.md",
        "Prior Art" => "others.md",
    ],
)

deploydocs(;
    repo="github.com/tecosaur/XDG.jl",
    devbranch="main",
)
