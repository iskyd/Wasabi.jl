using Wasabi
using Documenter

DocMeta.setdocmeta!(Wasabi, :DocTestSetup, :(using Wasabi); recursive=true)

makedocs(;
    modules=[Wasabi],
    authors="Mattia <iskyd@proton.me>",
    repo="https://github.com/iskyd/Wasabi.jl/blob/{commit}{path}#{line}",
    sitename="Wasabi.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://iskyd.github.io/Wasabi.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "API" => "api.md",
        "Migrations" => "migrations.md",
        "Query Builder" => "querybuilder.md",
    ],
)

deploydocs(;
    repo="github.com/iskyd/Wasabi.jl",
    devbranch="main",
)
