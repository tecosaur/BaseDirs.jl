using BaseDirs
using Test

# This test suite assumes it is running on a "default" system,
# where no customisations apply.

usr = homedir()

if Sys.isapple()
    @testset "Dirs" begin
        @testset "Base" begin
            @test BaseDirs.DATA_HOME[] == "$usr/Library/Application Support"
            @test BaseDirs.DATA_DIRS[] == ["/Library/Application Support"]
            @test BaseDirs.CONFIG_HOME[] == "$usr/Library/Application Support"
            @test BaseDirs.CONFIG_DIRS[] == ["/Library/Application Support"]
            @test BaseDirs.BIN_HOME[] == "/usr/local/bin"
            @test BaseDirs.STATE_HOME[] == "$usr/Library/Application Support"
            @test BaseDirs.CACHE_HOME[] == "$usr/Library/Caches"
            @test BaseDirs.RUNTIME_DIR[] == "$usr/Library/Application Support"
        end
        @testset "User" begin
            @test BaseDirs.DESKTOP_DIR[] == "$usr/Desktop"
            @test BaseDirs.DOWNLOAD_DIR[] == "$usr/Downloads"
            @test BaseDirs.DOCUMENTS_DIR[] == "$usr/Documents"
            @test BaseDirs.MUSIC_DIR[] == "$usr/Music"
            @test BaseDirs.PICTURES_DIR[] == "$usr/Pictures"
            @test BaseDirs.VIDEOS_DIR[] == "$usr/Videos"
            @test BaseDirs.TEMPLATES_DIR[] == "$usr/Templates"
            @test BaseDirs.PUBLICSHARE_DIR[] == "$usr/Public"
        end
        @testset "Other" begin
            @test BaseDirs.APPLICATIONS_DIRS[] == ["/Applications"]
            @test BaseDirs.FONTS_DIRS[] == ["$usr/Library/Fonts", "/Library/Fonts", "/System/Library/Fonts", "/System/Library/Fonts/Supplemental", "/Network/Library/Fonts"]
        end
    end
    @testset "User" begin
        @test BaseDirs.User.data() == "$usr/Library/Application Support"
        @test BaseDirs.User.config() == "$usr/Library/Application Support"
        @test BaseDirs.User.bin() == "/usr/local/bin"
        @test BaseDirs.User.state() == "$usr/Library/Application Support"
        @test BaseDirs.User.cache() == "$usr/Library/Caches"
        @test BaseDirs.User.runtime() == "$usr/Library/Application Support"
        @test BaseDirs.User.desktop() == "$usr/Desktop"
        @test BaseDirs.User.downloads() == "$usr/Downloads"
        @test BaseDirs.User.documents() == "$usr/Documents"
        @test BaseDirs.User.music() == "$usr/Music"
        @test BaseDirs.User.pictures() == "$usr/Pictures"
        @test BaseDirs.User.videos() == "$usr/Videos"
        @test BaseDirs.User.templates() == "$usr/Templates"
        @test BaseDirs.User.public() == "$usr/Public"
        @test BaseDirs.User.fonts() == ["$usr/Library/Fonts"]
        @test BaseDirs.User.applications() == String[]
    end
    @testset "System" begin
        @test BaseDirs.System.data() == ["/Library/Application Support"]
        @test BaseDirs.System.config() == ["/Library/Application Support"]
        @test BaseDirs.System.fonts() == ["/Library/Fonts", "/System/Library/Fonts", "/System/Library/Fonts/Supplemental", "/Network/Library/Fonts"]
        @test BaseDirs.System.applications() == ["/Applications"]
    end
    @testset "Other" begin
        @test BaseDirs.data() == ["$usr/Library/Application Support", "/Library/Application Support"]
        @test BaseDirs.config() == ["$usr/Library/Application Support", "/Library/Application Support"]
        @test BaseDirs.fonts() == ["$usr/Library/Fonts", "/Library/Fonts", "/System/Library/Fonts", "/System/Library/Fonts/Supplemental", "/Network/Library/Fonts"]
        @test BaseDirs.applications() == ["/Applications"]
    end
    @testset "Project" begin
        @test BaseDirs.projectpath(BaseDirs.Project("a")) == "lang.julia.a/"
        @test BaseDirs.projectpath(BaseDirs.Project("a"), "?") == "lang.julia.a/"
        @test BaseDirs.projectpath(BaseDirs.Project("Hey There")) == "lang.julia.Hey-There/"
    end
    @test isnothing(BaseDirs.reload())
elseif Sys.isunix()
    uid = rstrip(read(`id -u`, String))
    @testset "Dirs" begin
        @testset "Base" begin
            @test BaseDirs.DATA_HOME[] == "$usr/.local/share"
            @test BaseDirs.DATA_DIRS[] == ["/usr/local/share", "/usr/share"]
            @test BaseDirs.CONFIG_HOME[] == "$usr/.config"
            @test BaseDirs.CONFIG_DIRS[] == ["/etc/xdg"]
            @test BaseDirs.BIN_HOME[] == "$usr/.local/bin"
            @test BaseDirs.STATE_HOME[] == "$usr/.local/state"
            @test BaseDirs.CACHE_HOME[] == "$usr/.cache"
            @test BaseDirs.RUNTIME_DIR[] == "/run/user/$uid"
        end
        @testset "User" begin
            @test BaseDirs.DESKTOP_DIR[] == "$usr/Desktop"
            @test BaseDirs.DOWNLOAD_DIR[] == "$usr/Downloads"
            @test BaseDirs.DOCUMENTS_DIR[] == "$usr/Documents"
            @test BaseDirs.MUSIC_DIR[] == "$usr/Music"
            @test BaseDirs.PICTURES_DIR[] == "$usr/Pictures"
            @test BaseDirs.VIDEOS_DIR[] == "$usr/Videos"
            @test BaseDirs.TEMPLATES_DIR[] == "$usr/Templates"
            @test BaseDirs.PUBLICSHARE_DIR[] == "$usr/Public"
        end
        @testset "Other" begin
            @test BaseDirs.APPLICATIONS_DIRS[] == ["$usr/.local/share/applications", "/usr/local/share/applications", "/usr/share/applications"]
            @test BaseDirs.FONTS_DIRS[] == ["$usr/.local/share/fonts", "$usr/.fonts", "/usr/local/share/fonts", "/usr/share/fonts"]
        end
    end
    @testset "User" begin
        @test BaseDirs.User.data() == "$usr/.local/share"
        @test BaseDirs.User.config() == "$usr/.config"
        @test BaseDirs.User.bin() == "$usr/.local/bin"
        @test BaseDirs.User.state() == "$usr/.local/state"
        @test BaseDirs.User.cache() == "$usr/.cache"
        @test BaseDirs.User.runtime() == "/run/user/$uid"
        @test BaseDirs.User.desktop() == "$usr/Desktop"
        @test BaseDirs.User.downloads() == "$usr/Downloads"
        @test BaseDirs.User.documents() == "$usr/Documents"
        @test BaseDirs.User.music() == "$usr/Music"
        @test BaseDirs.User.pictures() == "$usr/Pictures"
        @test BaseDirs.User.videos() == "$usr/Videos"
        @test BaseDirs.User.templates() == "$usr/Templates"
        @test BaseDirs.User.public() == "$usr/Public"
        @test BaseDirs.User.fonts() == ["$usr/.local/share/fonts", "$usr/.fonts"]
        @test BaseDirs.User.applications() == ["$usr/.local/share/applications"]
    end
    @testset "System" begin
        @test BaseDirs.System.data() == ["/usr/local/share", "/usr/share"]
        @test BaseDirs.System.config() == ["/etc/xdg"]
        @test BaseDirs.System.fonts() == ["/usr/local/share/fonts", "/usr/share/fonts"]
        @test BaseDirs.System.applications() == ["/usr/local/share/applications", "/usr/share/applications"]
    end
    @testset "Other" begin
        @test BaseDirs.data() == ["$usr/.local/share", "/usr/local/share", "/usr/share"]
        @test BaseDirs.config() == ["$usr/.config", "/etc/xdg"]
        @test BaseDirs.fonts() == ["$usr/.local/share/fonts", "$usr/.fonts", "/usr/local/share/fonts", "/usr/share/fonts"]
        @test BaseDirs.applications() == ["$usr/.local/share/applications", "/usr/local/share/applications", "/usr/share/applications"]
    end
    @testset "Project" begin
        @test BaseDirs.projectpath(BaseDirs.Project("a")) == "julia/a/"
        @test BaseDirs.projectpath(BaseDirs.Project("a"), "?") == "julia/a/"
        @test BaseDirs.projectpath(BaseDirs.Project("Hey There")) == "julia/heythere/"
    end
    @testset "File creation" begin
        filepath = "$usr/.local/share/julia/a/my_base_dirs_julia_test_file"
        @test BaseDirs.User.data(BaseDirs.Project("a"), "my_base_dirs_julia_test_file") == filepath
        rm(filepath, force=true)
        try
            @test BaseDirs.User.data(BaseDirs.Project("a"), "my_base_dirs_julia_test_file", create=true) == filepath
            @test isfile(filepath)
        finally
            rm(filepath, force=true)
        end
    end
    @testset "Folder creation" begin
        folderpath = "$usr/.local/share/julia/a/my_base_dirs_julia_test_dir/"
        @test BaseDirs.User.data(BaseDirs.Project("a"), "my_base_dirs_julia_test_dir/") == folderpath
        rm(folderpath, force=true)
        try
            @test BaseDirs.User.data(BaseDirs.Project("a"), "my_base_dirs_julia_test_dir/", create=true) == folderpath
            @test isdir(folderpath)
        finally
            rm(folderpath, force=true)
        end
    end
    @testset "Executable creation" begin
        rm("$usr/.local/bin/my_base_dirs_julia_test_binary", force=true)
        try
            exec = BaseDirs.User.bin("my_base_dirs_julia_test_binary", create=true)
            @test exec == "$usr/.local/bin/my_base_dirs_julia_test_binary"
            @test isfile(exec)
            @test stat(exec).mode & 0o001 != 0
            @test exec == BaseDirs.User.bin("my_base_dirs_julia_test_binary", create=true)
            @test exec == BaseDirs.User.bin(BaseDirs.Project("my_base_dirs_julia_test_binary"))
        finally
            rm("$usr/.local/bin/my_base_dirs_julia_test_binary", force=true)
        end
    end
    @test isnothing(BaseDirs.reload())
    @testset "User dirs" begin
        isfile("$usr/.config/user-dirs.dirs") &&
            mv("$usr/.config/user-dirs.dirs", "$usr/.config/user-dirs.dirs.backup")
        try
            write("$usr/.config/user-dirs.dirs",
                  """
                  XDG_DESKTOP_DIR="\$HOME/Workbench"
                  # A commented line
                  an invalid line
                  XDG_DOWNLOAD_DIR=/tmp/Downloads
                  XDG_TEMPLATES_DIR=/=Templates=
                  XDG_INVALID="???"
                  """)
            @test isnothing(BaseDirs.reload())
            @test BaseDirs.User.desktop() == "$usr/Workbench"
            @test BaseDirs.User.downloads() == "/tmp/Downloads"
            @test BaseDirs.User.templates() == "/=Templates="
        finally
            rm("$usr/.config/user-dirs.dirs", force=true)
            isfile("$usr/.config/user-dirs.dirs.backup") &&
                mv("$usr/.config/user-dirs.dirs.backup", "$usr/.config/user-dirs.dirs")
        end
    end
elseif Sys.iswindows()
    @testset "OS specific" begin
        fieldvals(x::T) where {T} = ntuple(fieldcount(T)) do i
            getfield(x, i)
        end
        @test fieldvals(BaseDirs.relevantfolders()) == fieldvals(BaseDirs.RelevantFolders(
            "C:", "C:\\Windows", "C:\\ProgramData",
            "$usr\\AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs",
            "C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Programs",
            "C:\\Users", "$usr\\AppData\\Roaming", "$usr\\AppData\\Local",
            "$usr\\Desktop", "$usr\\Downloads", "$usr\\Documents",
            "$usr\\Music", "$usr\\Pictures", "$usr\\Videos",
            "$usr\\AppData\\Roaming\\Microsoft\\Windows\\Templates",
            "C:\\Users\\Public", "C:\\Windows\\Fonts"))
    end
    @testset "Dirs" begin
        @testset "Base" begin
            @test BaseDirs.DATA_HOME[] == "$usr\\AppData\\Roaming"
            @test BaseDirs.DATA_DIRS[] == ["C:\\ProgramData"]
            @test BaseDirs.CONFIG_HOME[] == "$usr\\AppData\\Roaming"
            @test BaseDirs.CONFIG_DIRS[] == ["C:\\ProgramData"]
            @test BaseDirs.BIN_HOME[] == "$usr\\bin"
            @test BaseDirs.STATE_HOME[] == "$usr\\AppData\\Local"
            @test BaseDirs.CACHE_HOME[] == "$usr\\AppData\\Local\\cache"
            @test BaseDirs.RUNTIME_DIR[] == "$usr\\AppData\\Local"
        end
        @testset "User" begin
            @test BaseDirs.DESKTOP_DIR[] == "$usr\\Desktop"
            @test BaseDirs.DOWNLOAD_DIR[] == "$usr\\Downloads"
            @test BaseDirs.DOCUMENTS_DIR[] == "$usr\\Documents"
            @test BaseDirs.MUSIC_DIR[] == "$usr\\Music"
            @test BaseDirs.PICTURES_DIR[] == "$usr\\Pictures"
            @test BaseDirs.VIDEOS_DIR[] == "$usr\\Videos"
            @test BaseDirs.TEMPLATES_DIR[] == "$usr\\AppData\\Roaming\\Microsoft\\Windows\\Templates"
            @test BaseDirs.PUBLICSHARE_DIR[] == "C:\\Users\\Public"
        end
        @testset "Other" begin
            @test BaseDirs.APPLICATIONS_DIRS[] == ["$usr\\AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs", "C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Programs"]
            @test BaseDirs.FONTS_DIRS[] == ["C:\\Windows\\Fonts", "$usr\\AppData\\Local\\Microsoft\\Windows\\Fonts"]
        end
    end
    @testset "User" begin
        @test BaseDirs.User.data() == "$usr\\AppData\\Roaming"
        @test BaseDirs.User.config() == "$usr\\AppData\\Roaming"
        @test BaseDirs.User.bin() == "$usr\\bin"
        @test BaseDirs.User.state() == "$usr\\AppData\\Local"
        @test BaseDirs.User.cache() == "$usr\\AppData\\Local\\cache"
        @test BaseDirs.User.runtime() == "$usr\\AppData\\Local"
        @test BaseDirs.User.desktop() == "$usr\\Desktop"
        @test BaseDirs.User.downloads() == "$usr\\Downloads"
        @test BaseDirs.User.documents() == "$usr\\Documents"
        @test BaseDirs.User.music() == "$usr\\Music"
        @test BaseDirs.User.pictures() == "$usr\\Pictures"
        @test BaseDirs.User.videos() == "$usr\\Videos"
        @test BaseDirs.User.templates() == "$usr\\AppData\\Roaming\\Microsoft\\Windows\\Templates"
        @test BaseDirs.User.public() == "C:\\Users\\Public"
        @test BaseDirs.User.fonts() == ["$usr\\AppData\\Local\\Microsoft\\Windows\\Fonts"]
        @test BaseDirs.User.applications() == ["$usr\\AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs"]
    end
    @testset "System" begin
        @test BaseDirs.System.data() == ["C:\\ProgramData"]
        @test BaseDirs.System.config() == ["C:\\ProgramData"]
        @test BaseDirs.System.fonts() == ["C:\\Windows\\Fonts"]
        @test BaseDirs.System.applications() == ["C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Programs"]
    end
    @testset "Others" begin
        @test BaseDirs.data() == ["$usr\\AppData\\Roaming", "C:\\ProgramData"]
        @test BaseDirs.config() == ["$usr\\AppData\\Roaming", "C:\\ProgramData"]
        @test BaseDirs.fonts() == ["C:\\Windows\\Fonts", "$usr\\AppData\\Local\\Microsoft\\Windows\\Fonts"]
        @test BaseDirs.applications() == ["$usr\\AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs", "C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Programs"]
    end
    @testset "Projects" begin
        @test BaseDirs.projectpath(BaseDirs.Project("a")) == "julia\\a\\"
        @test BaseDirs.projectpath(BaseDirs.Project("a", org="b")) == "b\\a\\"
        @test BaseDirs.projectpath(BaseDirs.Project("a"), BaseDirs.DATA_HOME[]) == "julia\\a\\data\\"
        if BaseDirs.CONFIG_HOME[] != BaseDirs.DATA_HOME[]
            @test BaseDirs.projectpath(BaseDirs.Project("a"), BaseDirs.CONFIG_HOME[]) == "julia\\a\\config\\"
        end
        @test BaseDirs.projectpath(BaseDirs.Project("a"), BaseDirs.CACHE_HOME[]) == "julia\\a\\cache\\"
        @test BaseDirs.projectpath(BaseDirs.Project("a"), BaseDirs.STATE_HOME[]) == "julia\\a\\state\\"
    end
    @test isnothing(BaseDirs.reload())
end
