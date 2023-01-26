function reload()
    appsupport = "~/Library/Application Support"
    # Base directories
    @setxdg DATA_HOME appsupport
    @setxdgs DATA_DIRS ["/Library/Application Support"]
    @setxdg CONFIG_HOME appsupport
    @setxdgs CONFIG_DIRS ["/Library/Application Support"]
    @setxdg STATE_HOME appsupport
    @setxdg CACHE_HOME "~/Library/Caches"
    @setxdg RUNTIME_DIR appsupport
    @setxdg BIN_HOME let
        path = split(get(ENV, "PATH", ""), ':')
        binmaybe = [expanduser("~/.local/bin"),
                    "/opt/local/bin"]
        Iterators.flatten((Iterators.filter(p -> p in path, binmaybe),
                           "/usr/local/bin")) |> first
    end
    # User directories
    @setxdg DESKTOP_DIR "~/Desktop"
    @setxdg DOWNLOAD_DIR "~/Downloads"
    @setxdg DOCUMENTS_DIR "~/Documents"
    @setxdg MUSIC_DIR "~/Music"
    @setxdg PICTURES_DIR "~/Pictures"
    @setxdg VIDEOS_DIR "~/Videos"
    @setxdg TEMPLATES_DIR "~/Templates"
    @setxdg PUBLICSHARE_DIR "~/Public"
    # Other directories
    FONTS_DIRS[] = [expanduser("~/Library/Fonts"),
                    "/Library/Fonts",
                    "/System/Library/Fonts",
                    "/System/Library/Fonts/Supplemental",
                    "/Network/Library/Fonts"]
    APPLICATIONS_DIRS[] = ["/Applications"]
    nothing
end

projectpath(p::Project, _) = projectpath(p)
projectpath(p::Project) = string(join(split(p.qualifier, '.') |> reverse, '.'), '.',
                                 replace(p.org, r"[^A-Za-z0-9_-]" => '-'), '.',
                                 replace(p.name, r"[^A-Za-z0-9_-]" => '-'), '/')
