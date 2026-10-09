using Documenter
using ReferenceSystems

makedocs(
    sitename = "ReferenceSystems",
    modules = [
        ReferenceSystems,
        ReferenceSystems.TimeSystems,
        ReferenceSystems.CoordinateSystems,
    ],
    pages = [
        "Home" => "index.md",
        "Time Systems" => "time.md",
        "Coordinate Systems" => "coordinate.md",
        #"Earth Orientation" => "earth_orientation.md",
        "API Reference" => "api.md",
    ],
)

deploydocs(
    repo = "github.com/abhimhamane/ReferenceSystems.git",
    devbranch = "main",
)