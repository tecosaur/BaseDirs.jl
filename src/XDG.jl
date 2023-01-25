module XDG

# Base directory

const DATA_HOME = Ref("")
const DATA_DIRS = Ref([""])
const CONFIG_HOME = Ref("")
const CONFIG_DIRS = Ref([""])
const BIN_HOME = Ref("") # Not yet standardized.
const STATE_HOME = Ref("")
const CACHE_HOME = Ref("")
const RUNTIME_DIR = Ref("")

# User directories

const DESKTOP_DIR = Ref("")
const DOWNLOAD_DIR = Ref("")
const DOCUMENTS_DIR = Ref("")
const MUSIC_DIR = Ref("")
const PICTURES_DIR = Ref("")
const VIDEOS_DIR = Ref("")
const TEMPLATES_DIR = Ref("")
const PUBLICSHARE_DIR = Ref("")

# Other directories

const APPLICATIONS_DIRS = Ref([""])
const FONTS_DIRS = Ref([""])

function reload end

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

reload()

end
