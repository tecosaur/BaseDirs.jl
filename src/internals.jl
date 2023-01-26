# Helper functions and macros

module Internals

using ..XDG

export @defaccessor, @setxdg, @setxdgs

@static if Sys.isunix()
    macro setxdg(envvar::Symbol, default)
        quote $(esc(envvar))[] = get(ENV, $("XDG_$envvar"), expanduser($(esc(default)))) end
    end
else
    macro setxdg(envvar::Symbol, default)
        quote $(esc(envvar))[] = get(ENV, $("XDG_$envvar"), $(esc(default))) end
    end
end

macro setxdgs(envvar::Symbol, defaults)
    quote $(esc(envvar))[] = if haskey(ENV, $("XDG_$envvar"))
        split(ENV[$("XDG_$envvar")], ':')
    else $(esc(defaults)) end
    end
end

const NEW_BASEDIR_MODE = 0o700

ensurebasedir(path::String) =
    isdir(path) || mkpath(path, mode=NEW_BASEDIR_MODE)

function ensurepath(path::String)
    if !ispath(path)
        isdir(dirname(path)) ||
            mkpath(dirname(path))
        isempty(basename(path)) || isfile(path) ||
            touch(path)
    end
end

function resolvedirpath(basedir::String, pathcomponents::Union{Tuple, AbstractVector}; create::Bool=false)
    create && ensurebasedir(basedir)
    if isempty(pathcomponents)
        basedir
    else
        fullpath = joinpath(basedir, pathcomponents...)
        create && ensurepath(fullpath)
        fullpath
    end
end

resolvedirpaths(basedirs::Vector{String}, pathcomponents::Union{Tuple, AbstractVector}; create::Bool=false) =
    resolvedirpath.(basedirs, Ref(pathcomponents); create)

macro defaccessor(fnname::Symbol, var::Symbol)
    dirvar = Expr(:ref, Expr(:., :XDG, QuoteNode(var)))
    resolver = if getfield(XDG, var) isa Ref{Vector{String}}
        :resolvedirpaths else :resolvedirpath end
    quote
        $(esc(fnname))(pathcomponents...; create::Bool=false) =
            $resolver($dirvar, pathcomponents; create)
        $(esc(fnname))(project::XDG.Project, pathcomponents...; create::Bool=false) =
            $(esc(fnname))(XDG.projectpath(project, $dirvar), pathcomponents...; create)
    end
end

end
