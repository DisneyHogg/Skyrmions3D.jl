using Documenter, Skyrmions3D

makedocs(
    modules = [Skyrmions3D],
    format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true"),
    sitename = "Skyrmion3d.jl",
    authors = "Chris Halcrow",
    pages = [
        "Home" => "index.md",
        "Make, save and load" => "making_skyrmions.md",
        "Transform and Combine" => "transform.md",
        "Compute properties" => "properties.md",
        "Flow" => "flow.md",
        "Visualise" => "visualisation.md",
        "API" => "api.md",
        "Citations" => "citations.md",
        "Contribute" => "contributing.md",
    ],
    repo = Documenter.Remotes.GitHub("chrishalcrow", "Skyrmions3D.jl"),
    checkdocs = :exports,
)

deploydocs(; repo = "github.com/chrishalcrow/Skyrmions3D.jl")
