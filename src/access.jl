# Utilities for help in accessing/creating the relevant directories.

module User

using ..XDG
using ..Internals

bin(; create::Bool=false) = Internals.resolvedirpath(XDG.BIN_HOME[], (); create)
bin(name; create::Bool=false) =
    Internals.resolvedirpath(XDG.BIN_HOME[], (name,); create)
bin(project::XDG.Project; create::Bool=false) =
    Internals.resolvedirpath(XDG.BIN_HOME[], (project.name,); create)

@defaccessor data DATA_HOME
@defaccessor config CONFIG_HOME
@defaccessor state STATE_HOME
@defaccessor cache CACHE_HOME
@defaccessor runtime RUNTIME_DIR

fonts(pathcomponents...; kwargs...) =
    Internals.resolvedirpaths(filter(p -> startswith(p, homedir()), XDG.FONTS_DIRS[]),
                              pathcomponents; kwargs...)
applications(pathcomponents...; kwargs...) =
    Internals.resolvedirpaths(filter(p -> startswith(p, homedir()), XDG.APPLICATIONS_DIRS[]),
                              pathcomponents; kwargs...)

desktop(pathcomponents...)   = joinpath(XDG.DESKTOP_DIR[],   pathcomponents...)
downloads(pathcomponents...) = joinpath(XDG.DOWNLOAD_DIR[],  pathcomponents...)
documents(pathcomponents...) = joinpath(XDG.DOWNLOADS_DIR[], pathcomponents...)
music(pathcomponents...)     = joinpath(XDG.MUSIC_DIR[],     pathcomponents...)
pictures(pathcomponents...)  = joinpath(XDG.PICTURES_DIR[],  pathcomponents...)
videos(pathcomponents...)    = joinpath(XDG.VIDEOS_DIR[],    pathcomponents...)
templates(pathcomponents...) = joinpath(XDG.TEMPLATES_DIR[], pathcomponents...)
public(pathcomponents...)    = joinpath(XDG.PUBLIC_DIR[],    pathcomponents...)

end

# ---------

module System

using ..XDG
using ..Internals

@defaccessor data DATA_DIRS
@defaccessor config CONFIG_DIRS

fonts(pathcomponents...; kwargs...) =
    Internals.resolvedirpaths(filter(p -> !startswith(p, homedir()), XDG.FONTS_DIRS[]),
                              pathcomponents; kwargs...)
applications(pathcomponents...; kwargs...) =
    Internals.resolvedirpaths(filter(p -> !startswith(p, homedir()), XDG.APPLICATIONS_DIRS[]),
                              pathcomponents; kwargs...)

end

# ---------

@defaccessor data vcat(DATA_HOME[], DATA_DIRS[])
@defaccessor config vcat(CONFIG_HOME[], CONFIG_DIRS[])
@defaccessor fonts FONTS_DIRS
@defaccessor applications APPLICATIONS_DIRS
