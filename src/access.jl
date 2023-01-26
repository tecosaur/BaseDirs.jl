# Utilities for help in accessing/creating the relevant directories.

module User

using ..XDG
using ..Internals

function executabledir(; create::Bool=false)
    if create && !isdir(XDG.BIN_HOME)
        mkpath(XDG.BIN_HOME, mode=Internals.NEW_BASEDIR_MODE)
    end
    XDG.BIN_HOME
end

@defaccessor data DATA_HOME
@defaccessor config CONFIG_HOME
@defaccessor state STATE_HOME
@defaccessor cache CACHE_HOME

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

end
