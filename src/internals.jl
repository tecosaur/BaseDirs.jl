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

function resolvedirpaths(basedirs::Vector{String}, pathcomponents::Union{Tuple, AbstractVector}; create::Bool=false, existent::Bool=false)
    allpaths = resolvedirpath.(basedirs, Ref(pathcomponents); create)
    if existent
        filter(ispath, allpaths)
    else
        allpaths
    end
end

macro defaccessor(fnname::Symbol, var::Union{Symbol, Expr})
    dirvar = if var isa Symbol
        Expr(:ref, Expr(:., :XDG, QuoteNode(var)))
    else esc(var) end
    vecfns = (:vec, :vcat, :filter, :map, :push!, :pushfirst!) # a few that come to mind
    resolver = if (var isa Symbol && getfield(XDG, var) isa Ref{Vector{String}}) ||
          (var isa Expr && (var.head == :vect ||
                            (var.head == :call && var.args[1] in vecfns)))
        :resolvedirpaths
    else
        :resolvedirpath
    end
    quote
        $(esc(fnname))(pathcomponents...; kwargs...) =
            $resolver($dirvar, pathcomponents; kwargs...)
        $(esc(fnname))(project::XDG.Project, pathcomponents...; kwargs...) =
            $(esc(fnname))(XDG.projectpath(project, $dirvar), pathcomponents...; kwargs...)
    end
end

end
