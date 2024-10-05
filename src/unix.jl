"""
    parseuserdirs(configdir::String) -> Dict{Symbol, String}

Parse the `user-dirs.dirs` file that lies under `configdir`.

Returns a dict with all recognised entries of the file.

!!! warning "Warning: Private"
    This is _not_ part of the BaseDirs API.
"""
function parseuserdirs(configdir::String)
    validnames = ("XDG_DESKTOP_DIR", "XDG_DOWNLOAD_DIR", "XDG_TEMPLATES_DIR",
                  "XDG_PUBLICSHARE_DIR", "XDG_DOCUMENTS_DIR", "XDG_MUSIC_DIR",
                  "XDG_PICTURES_DIR", "XDG_VIDEOS_DIR")
    userdirsfile = joinpath(configdir, "user-dirs.dirs")
    entries = Dict{Symbol, String}()
    if isfile(userdirsfile)
        for line in Iterators.map(strip, eachline(userdirsfile))
            if !startswith(line, '#') && occursin('=', line)
                key, value = split(line, '=', limit=2)
                if key in validnames
                    if startswith(value, '"') && endswith(value, '"')
                        value = unescape_string(chop(value, head=1, tail=1))
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

function reload()
    # Base directories
    @setxdg DATA_HOME "~/.local/share"
    @setxdgs DATA_DIRS ["/usr/local/share", "/usr/share"]
    @setxdg CONFIG_HOME "~/.config"
    @setxdgs CONFIG_DIRS ["/etc/xdg"]
    @setxdg STATE_HOME "~/.local/state"
    @setxdg BIN_HOME "~/.local/bin"
    @setxdg CACHE_HOME "~/.cache"
    @setxdg RUNTIME_DIR joinpath("/run/user", string(Base.Libc.getuid()))
    # User directories
    userdirs = merge(parseuserdirs(first(CONFIG_DIRS[])),
                     parseuserdirs(CONFIG_HOME[]))
    @setxdg DESKTOP_DIR     get(userdirs, :XDG_DESKTOP_DIR,     "~/Desktop")
    @setxdg DOWNLOAD_DIR    get(userdirs, :XDG_DOWNLOAD_DIR,    "~/Downloads")
    @setxdg DOCUMENTS_DIR   get(userdirs, :XDG_DOCUMENTS_DIR,   "~/Documents")
    @setxdg MUSIC_DIR       get(userdirs, :XDG_MUSIC_DIR,       "~/Music")
    @setxdg PICTURES_DIR    get(userdirs, :XDG_PICTURES_DIR,    "~/Pictures")
    @setxdg VIDEOS_DIR      get(userdirs, :XDG_VIDEOS_DIR,      "~/Videos")
    @setxdg TEMPLATES_DIR   get(userdirs, :XDG_TEMPLATES_DIR,   "~/Templates")
    @setxdg PUBLICSHARE_DIR get(userdirs, :XDG_PUBLICSHARE_DIR, "~/Public")
    # Other directories
    FONTS_DIRS[] =
        append!([joinpath(DATA_HOME[], "fonts"), expanduser("~/.fonts")],
                [joinpath(d, "fonts") for d::String in DATA_DIRS[]]) |> unique
    APPLICATIONS_DIRS[] =
        append!([joinpath(DATA_HOME[], "applications")],
                [joinpath(d, "applications") for d::String in DATA_DIRS[]]) |> unique
    nothing
end

projectpath(p::Project, _) = projectpath(p)
projectpath(p::Project) =
    string(lowercase(replace(p.org, r"[^A-Za-z0-9_-]" => "")), '/',
           lowercase(replace(p.name, r"[^A-Za-z0-9_-]" => "")), '/')
