using Documenter
using ReferenceSystems

makedocs(
    sitename = "ReferenceSystems",
    modules = [
        ReferenceSystems,
        ReferenceSystems.TimeSystems,
    ],
    pages = [
        "Home" => "index.md",
        "Time Systems" => "time.md",
        #"Earth Orientation" => "earth_orientation.md",
        "API Reference" => "api.md",
    ],
)