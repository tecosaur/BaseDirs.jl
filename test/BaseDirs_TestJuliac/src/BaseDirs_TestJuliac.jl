module BaseDirs_TestJuliac

using BaseDirs

function @main(ARGS)
    println(Core.stdout, "Base directories",
            "\n\nSystem",
            "\n--------------------------",
            "\n- Data:\n  - ", join(BaseDirs.System.data(), "\n  - "),
            "\n- Config:\n  - ", join(BaseDirs.System.config(), "\n  - "),
            "\n- Fonts:\n  - ", join(BaseDirs.System.fonts(), "\n  - "),
            "\n- Applications:\n  - ", join(BaseDirs.System.applications(), "\n  - "))
    println(Core.stdout,
            "\nUser (Base)",
            "\n--------------------------",
            "\n- Data: ", BaseDirs.User.data(),
            "\n- Config: ", BaseDirs.User.config(),
            "\n- State: ", BaseDirs.User.state(),
            "\n- Cache: ", BaseDirs.User.cache(),
            "\n- Runtime: ", BaseDirs.User.runtime())
    println(Core.stdout,
            "\nUserdirs",
            "\n--------------------------",
            "\n- Desktop: ", BaseDirs.User.desktop(),
            "\n- Downloads: ", BaseDirs.User.downloads(),
            "\n- Documents: ", BaseDirs.User.documents(),
            "\n- Music: ", BaseDirs.User.music(),
            "\n- Videos: ", BaseDirs.User.videos(),
            "\n- Templates: ", BaseDirs.User.templates(),
            "\n- Public: ", BaseDirs.User.public(),
            )
    proj = BaseDirs.App(@__MODULE__)
    println(Core.stdout, "\nProject example",
            "\n--------------------------",
            "\n- Data:\n  - ", join(BaseDirs.data(proj), "\n  - "),
            "\n- Config:\n  - ", join(BaseDirs.config(proj), "\n  - "),
            "\n- State: ", BaseDirs.state(proj),
            "\n- Cache: ", BaseDirs.cache(proj),
            "\n- Runtime: ", BaseDirs.runtime(proj)
            )
    # Path components and keyword arguments take separate (specialised) code paths
    println(Core.stdout, "\nProject files",
            "\n--------------------------",
            "\n- Settings:\n  - ", join(BaseDirs.config(proj, "settings.toml"), "\n  - "),
            "\n- Index: ", BaseDirs.User.cache(proj, "index", "db"; create=false),
            "\n- Existing fonts:\n  - ", join(BaseDirs.fonts(; existent=true), "\n  - "))
    0
end

end
