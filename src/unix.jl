"""
    SYSTEMD_SERVICE

Whether the current process is a systemd service.
"""
SYSTEMD_SERVICE::Bool = false

"""
    SYSTEMD_DIRS

Sandboxed directories provided by systemd, if running as a systemd service.

These are handled according to Table 2 of [systemd.exec(5) Sandboxing](https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html#id-1.14.5.3.6.3):

| Directory                   | Below path for system units | Below path for user units  | Environment variable set  |
|:----------------------------|:----------------------------|:---------------------------|:--------------------------|
| `RuntimeDirectory=%d`       | `/run/%d`                   | `\$XDG_RUNTIME_DIR/%d`      | `RUNTIME_DIRECTORY`       |
| `StateDirectory=%d`         | `/var/lib/%d`               | `\$XDG_STATE_HOME/%d`       | `STATE_DIRECTORY`         |
| `CacheDirectory=%d`         | `/var/cache/%d`             | `\$XDG_CACHE_HOME/%d`       | `CACHE_DIRECTORY`         |
| `LogsDirectory=%d`          | `/var/log/%d`               | `\$XDG_STATE_HOME/log/%d`   | `LOGS_DIRECTORY`          |
| `ConfigurationDirectory=%d` | `/etc/%d`                   | `\$XDG_CONFIG_HOME/%d`      | `CONFIGURATION_DIRECTORY` |

Recognition of these directories is particularly important when a service is run
under a [`DynamicUser`](https://0pointer.net/blog/dynamic-users-with-systemd.html)
and trying to use the "usual" directories is liable to cause permissions errors.

It is possible for multiple directories (separated with `:`) to be set, in which case
we take the first one for consistency with the non-systemd behaviour.
"""
SYSTEMD_DIRS::@NamedTuple{runtime::String, state::String, cache::String, logs::String, config::String} =
    (runtime = "", state = "", cache = "", logs = "", config = "")

"""
    userdirhash(name::AbstractString) -> UInt8

Hash `name` by its fourth byte, which perfectly maps `USER_DIR_NAMES` onto `0:8`.
"""
userdirhash(name::AbstractString) = ((codeunit(name, 4) ⊻ 0x2a) * 0xec) >> 4

"""
The XDG user directories, as named in `user-dirs.defaults` (and, wrapped as
`XDG_<name>_DIR`, `user-dirs.dirs`), ordered by `userdirhash`.
"""
const USER_DIR_NAMES = let names = ("DESKTOP", "DOWNLOAD", "TEMPLATES", "PUBLICSHARE",
                                    "DOCUMENTS", "MUSIC", "PICTURES", "PROJECTS", "VIDEOS")
    names[sortperm(collect(map(userdirhash, names)))]
end

"""
    userdirindex(name::AbstractString) -> Union{Int, Nothing}

Find the index of `name` in `USER_DIR_NAMES`, or `nothing` if it isn't one.
"""
function userdirindex(name::AbstractString)
    ncodeunits(name) >= 4 || return nothing
    index = userdirhash(name) + 1
    index <= length(USER_DIR_NAMES) && USER_DIR_NAMES[index] == name ? Int(index) : nothing
end

"""
    readfile(path::String) -> String

Read the file at `path`, or return `""` if it's missing or unreadable.
"""
function readfile(path::String)
    ispath(path) || return "" # Much cheaper than catching the error from `read`
    try
        read(path, String)
    catch err
        err isa Union{SystemError, Base.IOError} || rethrow()
        ""
    end
end

"""
    parseuserdirs!(userdirs::Vector{String}, configdir::String) -> userdirs

Update `userdirs` (ordered as `USER_DIR_NAMES`) with the entries of the
`user-dirs.dirs` file that lies under `configdir`.
"""
function parseuserdirs!(userdirs::Vector{String}, configdir::String)
    # As in xdg-user-dir-lookup.c, a backslash makes the next character literal
    function shellunescape(value::SubString{String})
        occursin('\\', value) || return value
        out = IOBuffer(sizehint=ncodeunits(value))
        escaped = false
        for char in value
            if char == '\\' && !escaped
                escaped = true
            else
                print(out, char)
                escaped = false
            end
        end
        escaped && print(out, '\\')
        SubString(String(take!(out)))
    end
    home = homedir()
    for line in Iterators.map(strip, eachsplit(readfile(joinpath(configdir, "user-dirs.dirs")), '\n'))
        startswith(line, '#') && continue
        eq = findfirst('=', line)
        isnothing(eq) && continue
        key, value = SubString(line, 1, prevind(line, eq)), SubString(line, nextind(line, eq))
        startswith(key, "XDG_") && endswith(key, "_DIR") || continue
        index = userdirindex(chop(key, head=4, tail=4))
        isnothing(index) && continue
        if startswith(value, '"') && endswith(value, '"')
            value = shellunescape(chop(value, head=1, tail=1))
        end
        path = if startswith(value, "\$HOME")
            string(home, chopprefix(value, "\$HOME"))
        else
            String(value)
        end
        startswith(path, '/') && (userdirs[index] = path)
    end
    userdirs
end

"""
    parsesystemuserdirs!(userdirs::Vector{String}, configdir::String) -> userdirs

Update `userdirs` (ordered as `USER_DIR_NAMES`) with the entries of the system
`user-dirs.defaults` file that lies under `configdir`.

This is the distribution-provided seed read by `xdg-user-dirs-update`. Unlike the
per-user [`parseuserdirs!`](@ref) file, lines take the form `<NAME>=<path>` with a
bare key (no `XDG_` prefix or `_DIR` suffix) and an unquoted path relative to the
home directory, e.g. `DESKTOP=Desktop`.
"""
function parsesystemuserdirs!(userdirs::Vector{String}, configdir::String)
    home = homedir()
    for line in Iterators.map(strip, eachsplit(readfile(joinpath(configdir, "user-dirs.defaults")), '\n'))
        startswith(line, '#') && continue
        eq = findfirst('=', line)
        isnothing(eq) && continue
        index = userdirindex(SubString(line, 1, prevind(line, eq)))
        value = SubString(line, nextind(line, eq))
        if !isnothing(index) && !isempty(value)
            userdirs[index] = joinpath(home, value)
        end
    end
    userdirs
end

function reload()
    # Systemd detection
    @static if Sys.islinux()
        cgroup = chomp(readfile("/proc/self/cgroup"))
        global SYSTEMD_SERVICE = startswith(cgroup, "0::") && endswith(cgroup, ".service")
        global SYSTEMD_DIRS = if SYSTEMD_SERVICE
            (runtime = first(eachsplit(get(ENV, "RUNTIME_DIRECTORY", ""), ':')),
             state   = first(eachsplit(get(ENV, "STATE_DIRECTORY", ""), ':')),
             cache   = first(eachsplit(get(ENV, "CACHE_DIRECTORY", ""), ':')),
             logs    = first(eachsplit(get(ENV, "LOGS_DIRECTORY", ""), ':')),
             config  = first(eachsplit(get(ENV, "CONFIGURATION_DIRECTORY", ""), ':')))
        else
            (runtime = "", state = "", cache = "", logs = "", config = "")
        end
    end
    # Base directories
    @setxdg DATA_HOME "~/.local/share"
    @setxdgs DATA_DIRS ["/usr/local/share", "/usr/share"]
    @setxdg CONFIG_HOME SYSTEMD_DIRS.config "~/.config"
    @setxdgs CONFIG_DIRS ["/etc/xdg"]
    @setxdg STATE_HOME SYSTEMD_DIRS.state "~/.local/state"
    # TODO: Introduce LOGS_HOME?
    @setxdg BIN_HOME "~/.local/bin"
    @setxdg CACHE_HOME SYSTEMD_DIRS.cache "~/.cache"
    @setxdg RUNTIME_DIR SYSTEMD_DIRS.runtime joinpath("/run/user", string(Base.Libc.getuid()))
    # User directories
    userdirs = fill("", length(USER_DIR_NAMES))
    for dir in Iterators.reverse(CONFIG_DIRS)
        parsesystemuserdirs!(userdirs, dir)
    end
    parseuserdirs!(userdirs, CONFIG_HOME)
    userdir(name, default) =
        let path = userdirs[userdirindex(name)::Int]
            if isempty(path) default else path end
        end
    @setxdg DESKTOP_DIR     userdir("DESKTOP",     "~/Desktop")
    @setxdg DOWNLOAD_DIR    userdir("DOWNLOAD",    "~/Downloads")
    @setxdg DOCUMENTS_DIR   userdir("DOCUMENTS",   "~/Documents")
    @setxdg PROJECTS_DIR    userdir("PROJECTS",    "~/Projects")
    @setxdg MUSIC_DIR       userdir("MUSIC",       "~/Music")
    @setxdg PICTURES_DIR    userdir("PICTURES",    "~/Pictures")
    @setxdg VIDEOS_DIR      userdir("VIDEOS",      "~/Videos")
    @setxdg TEMPLATES_DIR   userdir("TEMPLATES",   "~/Templates")
    @setxdg PUBLICSHARE_DIR userdir("PUBLICSHARE", "~/Public")
    # Other directories
    # Few enough paths that a linear scan beats hashing (in both time and code size)
    distinct(paths) = foldl((seen, path) -> path in seen ? seen : push!(seen, path), paths; init=String[])
    global FONTS_DIRS = distinct(Iterators.flatten((
        (joinpath(DATA_HOME, "fonts"), expanduser("~/.fonts")),
        (joinpath(d, "fonts") for d::String in DATA_DIRS))))
    global APPLICATIONS_DIRS = distinct(Iterators.flatten((
        (joinpath(DATA_HOME, "applications"),),
        (joinpath(d, "applications") for d::String in DATA_DIRS))))
    nothing
end

"""
    plainascii(s::String) -> String

Convert a string to a certain 'plain' ASCII form.

This is done by removing all non-alphanumeric characters (besides `_` and `-`),
and putting all letters in lower case.

While this could easily be done with a regex, unlike regex
replacement this can be precompiled, reducing TTFX.
"""
Base.@assume_effects :foldable function plainascii(s::String)
    isvalid(b::UInt8) = UInt8('0') <= b <= UInt8('9') ||
        UInt8('a') <= b <= UInt8('z') ||
        b in (UInt8('_'), UInt8('-'))
    all(isvalid, codeunits(s)) && return s
    out = sizehint!(UInt8[], ncodeunits(s))
    for b in codeunits(s)
        if isvalid(b)
            push!(out, b)
        elseif UInt8('A') <= b <= UInt8('Z')
            push!(out, b ⊻ 0x20) # lowercase
        end
    end
    String(out)
end

applicationpath(app::App, ::Symbol, parent) = applicationpath(app, parent)

function applicationpath(app::App, parent::String)
    # For quick exact matching, we can consider the pointers of
    # the strings in SYSTEMD_DIRS.
    if SYSTEMD_SERVICE && pointer(parent) ∈ map(pointer, SYSTEMD_DIRS)
        ""
    else
        applicationpath(app)
    end
end

function applicationpath(app::App, parents::Vector{String})
    if isempty(parents)
        applicationpath(app)
    else
        applicationpath(app, first(parents))
    end
end

applicationpath(app::App) =
    string(plainascii(app.org), '/', plainascii(app.name), '/')
