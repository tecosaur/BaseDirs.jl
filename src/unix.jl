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

@static if VERSION < v"1.11-"
    isreadable(path) = try open(Base.isreadable, path) catch; false end
end

"""
    parseuserdirs(configdir::String) -> Dict{Symbol, String}

Parse the `user-dirs.dirs` file that lies under `configdir`.

Returns a dict with all recognised entries of the file.
"""
function parseuserdirs(configdir::String)
    validnames = ("XDG_DESKTOP_DIR", "XDG_DOWNLOAD_DIR", "XDG_TEMPLATES_DIR",
                  "XDG_PUBLICSHARE_DIR", "XDG_DOCUMENTS_DIR", "XDG_MUSIC_DIR",
                  "XDG_PICTURES_DIR", "XDG_PROJECTS_DIR", "XDG_VIDEOS_DIR")
    userdirsfile = joinpath(configdir, "user-dirs.dirs")
    entries = Dict{Symbol, String}()
    if isreadable(userdirsfile) && isfile(userdirsfile)
        for line in Iterators.map(strip, eachline(userdirsfile))
            if !startswith(line, '#') && occursin('=', line)
                key, value = split(line, '=', limit=2)
                if key in validnames
                    if startswith(value, '"') && endswith(value, '"')
                        value = try
                            unescape_string(chop(value, head=1, tail=1))
                        catch
                            continue
                        end
                    end
                    if startswith(value, "\$HOME")
                        value = string(homedir(), chopprefix(value, "\$HOME"))
                    end
                    if startswith(value, '/')
                        entries[Symbol(key)] = value
                    end
                end
            end
        end
    end
    entries
end

"""
    parsesystemuserdirs(configdir::String) -> Dict{Symbol, String}

Parse the system `user-dirs.defaults` file that lies under `configdir`.

This is the distribution-provided seed read by `xdg-user-dirs-update`. Unlike the
per-user [`parseuserdirs`](@ref) file, lines take the form `<NAME>=<path>` with a
bare key (no `XDG_` prefix or `_DIR` suffix) and an unquoted path relative to the
home directory, e.g. `DESKTOP=Desktop`.

Returns a dict keyed by the corresponding `XDG_*_DIR` symbols, with values
resolved to absolute paths, so the result merges directly with `parseuserdirs`.
"""
function parsesystemuserdirs(configdir::String)
    validnames = ("DESKTOP", "DOWNLOAD", "TEMPLATES", "PUBLICSHARE",
                  "DOCUMENTS", "MUSIC", "PICTURES", "PROJECTS", "VIDEOS")
    defaultsfile = joinpath(configdir, "user-dirs.defaults")
    entries = Dict{Symbol, String}()
    if isreadable(defaultsfile) && isfile(defaultsfile)
        for line in Iterators.map(strip, eachline(defaultsfile))
            if !startswith(line, '#') && occursin('=', line)
                key, value = split(line, '=', limit=2)
                if key in validnames && !isempty(value)
                    entries[Symbol("XDG_", key, "_DIR")] = joinpath(homedir(), value)
                end
            end
        end
    end
    entries
end

function reload()
    # Systemd detection
    @static if Sys.islinux()
        cgroup = try readchomp("/proc/self/cgroup") catch; "" end
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
    userdirs = Dict{Symbol, String}()
    for dir in Iterators.reverse(CONFIG_DIRS)
        merge!(userdirs, parsesystemuserdirs(dir))
    end
    merge!(userdirs, parseuserdirs(CONFIG_HOME))
    @setxdg DESKTOP_DIR     get(userdirs, :XDG_DESKTOP_DIR,     "~/Desktop")
    @setxdg DOWNLOAD_DIR    get(userdirs, :XDG_DOWNLOAD_DIR,    "~/Downloads")
    @setxdg DOCUMENTS_DIR   get(userdirs, :XDG_DOCUMENTS_DIR,   "~/Documents")
    @setxdg PROJECTS_DIR    get(userdirs, :XDG_PROJECTS_DIR,    "~/Projects")
    @setxdg MUSIC_DIR       get(userdirs, :XDG_MUSIC_DIR,       "~/Music")
    @setxdg PICTURES_DIR    get(userdirs, :XDG_PICTURES_DIR,    "~/Pictures")
    @setxdg VIDEOS_DIR      get(userdirs, :XDG_VIDEOS_DIR,      "~/Videos")
    @setxdg TEMPLATES_DIR   get(userdirs, :XDG_TEMPLATES_DIR,   "~/Templates")
    @setxdg PUBLICSHARE_DIR get(userdirs, :XDG_PUBLICSHARE_DIR, "~/Public")
    # Other directories
    global FONTS_DIRS =
        append!([joinpath(DATA_HOME, "fonts"), expanduser("~/.fonts")],
                [joinpath(d, "fonts") for d::String in DATA_DIRS]) |> unique
    global APPLICATIONS_DIRS =
        append!([joinpath(DATA_HOME, "applications")],
                [joinpath(d, "applications") for d::String in DATA_DIRS]) |> unique
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
