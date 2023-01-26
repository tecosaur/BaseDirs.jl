# Helper functions and macros

module Internals

using ..XDG
using Base.Docs

export @defaccessor, @setxdg, @setxdgs

@static if Sys.isunix()
    macro setxdg(envvar::Symbol, default)
        quote $(esc(envvar))[] = if haskey(ENV, $("XDG_$envvar")) && !isempty(ENV[$("XDG_$envvar")])
            ENV[$("XDG_$envvar")] else expanduser($(esc(default))) end
        end
    end
else
    macro setxdg(envvar::Symbol, default)
        quote $(esc(envvar))[] = if haskey(ENV, $("XDG_$envvar")) && !isempty(ENV[$("XDG_$envvar")])
            ENV[$("XDG_$envvar")] else $(esc(default)) end
        end
    end
end

macro setxdgs(envvar::Symbol, defaults)
    quote $(esc(envvar))[] = if haskey(ENV, $("XDG_$envvar")) && !isempty(ENV[$("XDG_$envvar")])
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

function acessordoc(finfo::Union{Symbol, Tuple{String, Symbol}},
                    var::Union{Nothing, Symbol, Vector{Symbol}}=nothing;
                    plural::Bool=if isnothing(var) false
                    elseif var isa Vector true
                    else getfield(XDG, var) isa Ref{Vector{String}} end,
                    name::String=String(if fname isa Symbol fname else last(fname) end))
    fprefix, fname = if finfo isa Symbol; ("", finfo) else finfo end
    rettype = ifelse(plural, "Vector{String}", "String")
    dirprefix, dirterm = ifelse(plural, ("all", "directories"), ("the", "directory"))
    existentkwarg = ifelse(plural, " - `existent::Bool` (default `false`), filter out paths that do not exist.", "")
    vardoc = if var isa Vector && (dvars = filter(v -> haskey(Docs.meta(XDG), Docs.Binding(XDG, v)), var)) |> !isempty
        "\nThe returned path is based on the variables $(join(map(v -> "`XDG.$v`", dvars), ", ", ", and ")), which see.\n"
    elseif !isnothing(var) && haskey(Docs.meta(XDG), Docs.Binding(XDG, var))
        "\nThe returned path is based on the variable `XDG.$var`, which see.\n"
    else "" end
    kwargs = ifelse(plural, "; create, existent", "; create")
    """
    $fprefix$fname($kwargs) -> $rettype # $dirprefix $dirterm
    $fprefix$fname(parts...$kwargs) # $dirprefix $dirterm joined with parts
    $fprefix$fname(proj::Project$kwargs) # $dirprefix project-specific $dirterm
    $fprefix$fname(proj::Project, parts...$kwargs) # $dirprefix project-specific $dirterm joined with parts

Locate $dirprefix $name $dirterm. Optionally, a project and/or path components
can be provided as arguments, in which case they are joined with the $name
$dirterm as appropriate.
$vardoc
## Keyword arguments
 - `create::Bool` (default `false`), whether the path should be created if it does not exist.
   This takes care to create the base directories with the appropriate permissions ($(string(NEW_BASEDIR_MODE, base=8))).
$existentkwarg"""
end

end
