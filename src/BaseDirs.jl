module BaseDirs

@static if VERSION >= v"1.11"
    eval(Expr(:public, :System, :User, :Project, :reload, :data, :config,
              :fonts, :applications, :DATA_HOME, :DATA_DIRS, :CONFIG_HOME,
              :CONFIG_DIRS, :BIN_HOME, :STATE_HOME, :CACHE_HOME, :RUNTIME_DIR,
              :DESKTOP_DIR, :DOWNLOAD_DIR, :DOCUMENTS_DIR, :PICTURES_DIR,
              :VIDEO_DIR, :TEMPLATE_DIR, :PUBLICSHARE_DIR, :APPLICATIONS_DIRS,
              :FONTS_DIRS))
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
