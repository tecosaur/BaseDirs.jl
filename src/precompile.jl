# Precompilation statements
#
# We could only load these when `ccall(:jl_generating_output, Cint, ()) == 1`,
# however testing reveals that this makes a negligible difference to the overall
# latency.
#
# The aim here is to reduce the latency experienced by packages using `BaseDirs`.
# This means we want to balance "precompile everything" with compiled code size.
# As such, we'll focus on the most likely entry-points during package setup.
# This is mostly guesswork, but it seems sensible to think that during their setup
# packages would most likely check the User/System directories, possibly based
# on a particular `Project`.
#
# We'll proceed with that in mind, and re-adjust if it seems sensible to do so.

precompile(reload, ())

precompile(Project, (String,))
precompile(projectpath, (Project,))

precompile(User.bin, ())
precompile(User.bin, (String,))
precompile(User.bin, (Project,))

# Adds ~5ms to latency
for fn in (User.data, User.config, User.state, User.cache, User.runtime,
           System.data, System.config,
           data, config, fonts, applications)
    precompile(fn, ())
    precompile(fn, (String,))
    precompile(fn, (String, String))
    precompile(fn, (Project,))
    precompile(fn, (Project, String))
end

# Another ~5ms in latency, but this seems unlikely to be relevant
# during package initialisation/setup.
# for fn in (User.desktop, User.downloads, User.documents, User.music,
#            User.pictures, User.videos, User.templates, User.public,
#            User.fonts, User.applications, System.fonts, System.applications)
#     precompile(fn, ())
#     precompile(fn, (String,))
#     precompile(fn, (String, Vararg{String},))
# end

# We could use PrecompileTools to capture these base methods,
# however it actually end up ~doubling the TTFX along the way 😬.
#
# We're also only /really/ able to get the latency right down
# as of Julia 1.9, so let's manually check the results of `--trace-compile`
# with each minor version since then.

@static if VERSION >= v"1.11-alpha1"
    precompile(issorted, (Vector{String}, Base.Order.ReverseOrdering{Base.Order.ForwardOrdering}))
    precompile(replace, (String, Pair{Regex, String}))
    precompile(lowercase, (String,)) # This still appears in `--trace-compile` !?
    precompile(string, (String, Char, Vararg{Union{Char, String, Symbol}}))
elseif VERSION >= v"1.10"
    precompile(replace, (String, Pair{Regex, String})) # This still appears in `--trace-compile` !?
elseif VERSION >= v"1.9"
    # `--trace-compile` is empty
end
