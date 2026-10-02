# This implementation took a toll on my sanity over the many /hours/ it took to
# get right, as opposed to the handful of minutes darwin.jl and unix.jl took.

struct GUID
    d1::UInt32
    d2::UInt16
    d3::UInt16
    d4::NTuple{8, UInt8}
end

# A subset of https://learn.microsoft.com/en-us/windows/win32/shell/knownfolderid
const FOLDERID = (
    CommonPrograms         = GUID(0x0139d44e, 0x6afe, 0x49f2, (0x86, 0x90, 0x3d, 0xaf, 0xca, 0xe6, 0xff, 0xb8)),
  # CommonStartMenu        = GUID(0xa4115719, 0xd62e, 0x491d, (0xaa, 0x7c, 0xe7, 0x4b, 0x8b, 0xe3, 0xb0, 0x67)),
  # CommonStartup          = GUID(0x82a5ea35, 0xd9cd, 0x47c5, (0x96, 0x29, 0xe1, 0x5d, 0x2f, 0x71, 0x4e, 0x6e)),
  # CommonTemplates        = GUID(0xb94237e7, 0x57ac, 0x4347, (0x91, 0x51, 0xb0, 0x8c, 0x6c, 0x32, 0xd1, 0xf7)),
    Desktop                = GUID(0xb4bfcc3a, 0xdb2c, 0x424c, (0xb0, 0x29, 0x7f, 0xe9, 0x9a, 0x87, 0xc6, 0x41)),
    Documents              = GUID(0xfdd39ad0, 0x238f, 0x46af, (0xad, 0xb4, 0x6c, 0x85, 0x48, 0x03, 0x69, 0xc7)),
    Downloads              = GUID(0x374de290, 0x123f, 0x4565, (0x91, 0x64, 0x39, 0xc4, 0x92, 0x5e, 0x46, 0x7b)),
    Fonts                  = GUID(0xfd228cb7, 0xae11, 0x4ae3, (0x86, 0x4c, 0x16, 0xf3, 0x91, 0x0a, 0xb8, 0xfe)),
    LocalAppData           = GUID(0xf1b32785, 0x6fba, 0x4fcf, (0x9d, 0x55, 0x7b, 0x8e, 0x7f, 0x15, 0x70, 0x91)),
  # LocalAppDataLow        = GUID(0xa520a1a4, 0x1780, 0x4ff6, (0xbd, 0x18, 0x16, 0x73, 0x43, 0xc5, 0xaf, 0x16)),
    Music                  = GUID(0x4bd8d571, 0x6d19, 0x48d3, (0xbe, 0x97, 0x42, 0x22, 0x20, 0x08, 0x0e, 0x43)),
    Pictures               = GUID(0x33e28130, 0x4e1e, 0x4676, (0x83, 0x5a, 0x98, 0x39, 0x5c, 0x3b, 0xc3, 0xbb)),
    Profile                = GUID(0x5e6c858f, 0x0e22, 0x4760, (0x9a, 0xfe, 0xea, 0x33, 0x17, 0xb6, 0x71, 0x73)),
    ProgramData            = GUID(0x62ab5d82, 0xfdc1, 0x4dc3, (0xa9, 0xdd, 0x07, 0x0d, 0x1d, 0x49, 0x5d, 0x97)),
  # ProgramFiles           = GUID(0x905e63b6, 0xc1bf, 0x494e, (0xb2, 0x9c, 0x65, 0xb7, 0x32, 0xd3, 0xd2, 0x1a)),
  # ProgramFilesCommon     = GUID(0xf7f1ed05, 0x9f6d, 0x47a2, (0xaa, 0xae, 0x29, 0xd3, 0x17, 0xc6, 0xf0, 0x66)),
  # ProgramFilesCommonX64  = GUID(0x6365d5a7, 0x0f0d, 0x45e5, (0x87, 0xf6, 0x0d, 0xa5, 0x6b, 0x6a, 0x4f, 0x7d)),
  # ProgramFilesCommonX86  = GUID(0xde974d24, 0xd9c6, 0x4d3e, (0xbf, 0x91, 0xf4, 0x45, 0x51, 0x20, 0xb9, 0x17)),
  # ProgramFilesX64        = GUID(0x6d809377, 0x6af0, 0x444b, (0x89, 0x57, 0xa3, 0x77, 0x3f, 0x02, 0x20, 0x0e)),
  # ProgramFilesX86        = GUID(0x7c5a40ef, 0xa0fb, 0x4bfc, (0x87, 0x4a, 0xc0, 0xf2, 0xe0, 0xb9, 0xfa, 0x8e)),
    Programs               = GUID(0xa77f5d77, 0x2e2b, 0x44c3, (0xa6, 0xa2, 0xab, 0xa6, 0x01, 0x05, 0x4a, 0x51)),
    Public                 = GUID(0xdfdf76a2, 0xc82a, 0x4d63, (0x90, 0x6a, 0x56, 0x44, 0xac, 0x45, 0x73, 0x85)),
    RoamingAppData         = GUID(0x3eb685db, 0x65f9, 0x4cf6, (0xa0, 0x3a, 0xe3, 0xef, 0x65, 0x72, 0x9f, 0x3d)),
  # StartMenu              = GUID(0x625b53c3, 0xab48, 0x4ec1, (0xba, 0x1f, 0xa1, 0xef, 0x41, 0x46, 0xfc, 0x19)),
  # Startup                = GUID(0xb97d20bb, 0xf46a, 0x4c97, (0xba, 0x10, 0x5e, 0x36, 0x08, 0x43, 0x08, 0x54)),
  # System                 = GUID(0x1ac14e77, 0x02e7, 0x4e5d, (0xb7, 0x44, 0x2e, 0xb1, 0xae, 0x51, 0x98, 0xb7)),
  # SystemX86              = GUID(0xd65231b0, 0xb2f1, 0x4857, (0xa4, 0xce, 0xa8, 0xe7, 0xc6, 0xea, 0x7d, 0x27)),
    Templates              = GUID(0xa63293e8, 0x664e, 0x48db, (0xa0, 0x79, 0xdf, 0x75, 0x9e, 0x05, 0x09, 0xf7)),
  # UserProfiles           = GUID(0x0762d272, 0xc50a, 0x4bb0, (0xa3, 0x82, 0x69, 0x7d, 0xcd, 0x72, 0x9b, 0x80)),
  # UserProgramFiles       = GUID(0x5cd7aee2, 0x2219, 0x4a67, (0xb8, 0x5d, 0x6c, 0x9c, 0xe1, 0x56, 0x60, 0xcb)),
  # UserProgramFilesCommon = GUID(0xbcbd3057, 0xca5c, 0x4622, (0xb4, 0x2d, 0xbc, 0x56, 0xdb, 0x0a, 0xe5, 0x16)),
    Videos                 = GUID(0x18989b1d, 0x99b5, 0x455b, (0x84, 0x1c, 0xab, 0x7c, 0x74, 0xe4, 0xdd, 0xfc)),
    Windows                = GUID(0xf38bf404, 0x1d43, 0x42f2, (0x93, 0x05, 0x67, 0xde, 0x0b, 0x28, 0xfc, 0x23)))

function unsafe_utf16string(ptr::Ptr{UInt16})
    ptr == C_NULL && return
    len = 0
    while unsafe_load(ptr, len + 1) != 0
        len += 1
    end
    len == 0 && return ""
    buf = Vector{UInt16}(undef, len)
    unsafe_copyto!(pointer(buf), ptr, len)
    transcode(String, buf)
end

function knownfolder(guid::GUID)
    ptr = Ref(Ptr{UInt16}())
    err = ccall((:SHGetKnownFolderPath, "shell32"), stdcall, UInt32,
                (Ref{GUID}, Cuint, Ptr{Cvoid}, Ptr{Ptr{UInt16}}),
                Ref(guid), 0, C_NULL, ptr)
    if iszero(err)
        folder = unsafe_utf16string(ptr[])
        ccall((:CoTaskMemFree, "ole32.dll"), stdcall, Cvoid, (Ptr{Cvoid},), ptr[])
        folder
    end
end

function knownfolder(guid::GUID, envvars::Vector{String}, default::String)
    firstenv(envvars) =
        for envvar in envvars
            if haskey(ENV, envvar)
                return ENV[envvar]
            end
        end
    something(knownfolder(guid), firstenv(envvars), default)
end

knownfolder(guid::GUID, default::String) = something(knownfolder(guid), default)

const RELEVANT_FOLDERS =
    (:SystemDrive, :SystemRoot,
     :ProgramData, :Programs, :CommonPrograms,
     :Profile, :RoamingAppData, :LocalAppData,
     :Desktop, :Downloads, :Documents, :Music, :Pictures,
     :Videos, :Templates, :Public, :Fonts)

eval(Expr(:struct, true, :RelevantFolders,
          Expr(:block,
               map(f -> Expr(:(::), f, :String),
                   RELEVANT_FOLDERS)...)))

eval(Expr(:(=), Expr(:call, :RelevantFolders),
          Expr(:call, :RelevantFolders, fill("", length(RELEVANT_FOLDERS))...)))

function relevantfolders()
    rf = RelevantFolders()
    home = homedir()
    rf.SystemDrive = knownfolder(
        FOLDERID.Windows, ["SystemDrive", "SystemRoot", "windir"], home) |>
            splitdrive |> first
    rf.SystemRoot = knownfolder(
        FOLDERID.Windows, ["SystemRoot", "windir"], joinpath(rf.SystemDrive, "Windows"))
    rf.ProgramData = knownfolder(
        FOLDERID.ProgramData, ["ProgramData", "ALLUSERSPROFILE"], joinpath(rf.SystemDrive, "ProgramData"))
    rf.Profile = knownfolder(
        FOLDERID.Profile, joinpath(rf.SystemDrive, "Users"))
    rf.RoamingAppData = knownfolder(
        FOLDERID.RoamingAppData, ["APPDATA"], joinpath(home, "AppData", "Roaming"))
    rf.LocalAppData = knownfolder(
        FOLDERID.LocalAppData, ["LOCALAPPDATA"], joinpath(home, "AppData", "Local"))
    rf.Desktop = knownfolder(FOLDERID.Desktop, joinpath(home, "Desktop"))
    rf.Downloads = knownfolder(FOLDERID.Downloads, joinpath(home, "Downloads"))
    rf.Documents = knownfolder(FOLDERID.Documents, joinpath(home, "Documents"))
    rf.Music = knownfolder(FOLDERID.Music, joinpath(home, "Music"))
    rf.Pictures = knownfolder(FOLDERID.Pictures, joinpath(home, "Pictures"))
    rf.Videos = knownfolder(FOLDERID.Videos, joinpath(home, "Videos"))
    rf.Templates = knownfolder(
        FOLDERID.Templates, joinpath(rf.RoamingAppData, "Microsoft", "Windows", "Templates"))
    rf.Public = knownfolder(FOLDERID.Public, ["Public"], joinpath(rf.Profile, "Public"))
    rf.Fonts = knownfolder(FOLDERID.Fonts, joinpath(rf.SystemRoot, "Fonts"))
    rf.Programs = knownfolder(
        FOLDERID.Programs, joinpath(rf.RoamingAppData, "Microsoft", "Windows", "Start Menu", "Programs"))
    rf.CommonPrograms = knownfolder(
        FOLDERID.CommonPrograms, joinpath(rf.ProgramData, "Microsoft", "Windows", "Start Menu", "Programs"))
    rf
end

function reload()
    rf = relevantfolders()
    # Base directories
    @setxdg DATA_HOME rf.RoamingAppData
    @setxdgs DATA_DIRS [rf.ProgramData]
    @setxdg CONFIG_HOME rf.RoamingAppData
    @setxdgs CONFIG_DIRS [rf.ProgramData]
    @setxdg STATE_HOME rf.LocalAppData
    @setxdg CACHE_HOME joinpath(rf.LocalAppData, "cache")
    @setxdg RUNTIME_DIR rf.LocalAppData
    @setxdg BIN_HOME let
        path = split(get(ENV, "PATH", ""), ';')
        # REVIEW The list of checked directories here.
        # - Should `LocalAppData` be added?
        # - Should `<juliainstall>\bin` be (re-)used?
        binmaybe = [joinpath(homedir(), "bin"),
                    joinpath(rf.RoamingAppData, "bin"),
                    joinpath(rf.LocalAppData, "bin")]
        Iterators.flatten((Iterators.filter(p -> p in path, binmaybe),
                           (first(binmaybe),))) |> first
    end
    # User directories
    @setxdg DESKTOP_DIR rf.Desktop
    @setxdg DOWNLOAD_DIR rf.Downloads
    @setxdg DOCUMENTS_DIR rf.Documents
    @setxdg PROJECTS_DIR joinpath(rf.Profile, "Projects")
    @setxdg MUSIC_DIR rf.Music
    @setxdg PICTURES_DIR rf.Pictures
    @setxdg VIDEOS_DIR rf.Videos
    @setxdg TEMPLATES_DIR rf.Templates
    @setxdg PUBLICSHARE_DIR rf.Public
    # Other directories
    global FONTS_DIRS = [rf.Fonts, joinpath(rf.LocalAppData, "Microsoft", "Windows", "Fonts")]
    global APPLICATIONS_DIRS = [rf.Programs, rf.CommonPrograms]
    nothing
end

applicationpath(app::App, kind::Symbol, ::String) =
    joinpath(applicationpath(app), if kind === :data
                 "data\\"
             elseif kind === :config
                 "config\\"
             elseif kind === :cache
                 "cache\\"
             elseif kind === :state
                 "state\\"
             else
                 ""
             end)

function applicationpath(app::App, kind::Symbol, parents::Vector{String})
    if isempty(parents)
        applicationpath(app)
    else
        applicationpath(app, kind, first(parents))
    end
end

applicationpath(app::App) = joinpath(app.org, app.name, "")
