module BaseDirs

# Compat
@static if VERSION < v"1.8"
    # `chopsuffix` is then also imported within `internals.jl`
    function chopsuffix(s::Union{String, SubString{String}},
                        suffix::Union{String, SubString{String}})
        if !isempty(suffix) && endswith(s, suffix)
            astart = ncodeunits(s) - ncodeunits(suffix) + 1
            @inbounds SubString(s, firstindex(s), prevind(s, astart))
        else
            SubString(s)
        end
    end
    function chopprefix(s::Union{String, SubString{String}},
                        prefix::Union{String, SubString{String}})
        if startswith(s, prefix)
            SubString(s, 1 + ncodeunits(prefix))
        else
            SubString(s)
        end
    end
end

include("variables.jl")

function reload end
function projectpath end

struct Project
    name::AbstractString
    org::AbstractString
    qualifier::AbstractString
end

Project(name::AbstractString; org::AbstractString="julia", qualifier::AbstractString="lang") =
    Project(name, org, qualifier)

include("internals.jl")

using ..Internals

include("access.jl")

@static if Sys.isapple()
    const PLATFORM = :darwin
    include("darwin.jl")
elseif Sys.isunix()
    const PLATFORM = :unix
    include("unix.jl")
elseif Sys.iswindows()
    const PLATFORM = :nt
    include("nt.jl")
else
    error("Unsupported platform")
end

include("docstrings.jl")

const __init__ = reload

include("precompile.jl")

end
