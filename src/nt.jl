# This implementation took a toll on my sanity over the many /hours/ it took to
# get right, as opposed to the handful of minutes darwin.jl and unix.jl took.

struct StupidWindowsGUID
    d1::UInt32
    d2::UInt16
    d3::UInt16
    d4::NTuple{8, UInt8}
end

const KNOWN_FOLDER_IDS = Dict{Symbol, StupidWindowsGUID}(
    :AccountPictures        => StupidWindowsGUID(0x008ca0b1, 0x55b4, 0x4c56, (0xb8, 0xa8, 0x4d, 0xe4, 0xb2, 0x99, 0xd3, 0xbe)),
    :AddNewPrograms         => StupidWindowsGUID(0xde61d971, 0x5ebc, 0x4f02, (0xa3, 0xa9, 0x6c, 0x82, 0x89, 0x5e, 0x5c, 0x04)),
    :AdminTools             => StupidWindowsGUID(0x724ef170, 0xa42d, 0x4fef, (0x9f, 0x26, 0xb6, 0x0e, 0x84, 0x6f, 0xba, 0x4f)),
    :AllAppMods             => StupidWindowsGUID(0x7ad67899, 0x66af, 0x43ba, (0x91, 0x56, 0x6a, 0xad, 0x42, 0xe6, 0xc5, 0x96)),
    :AppCaptures            => StupidWindowsGUID(0xedc0fe71, 0x98d8, 0x4f4a, (0xb9, 0x20, 0xc8, 0xdc, 0x13, 0x3c, 0xb1, 0x65)),
    :AppDataDesktop         => StupidWindowsGUID(0xb2c5e279, 0x7add, 0x439f, (0xb2, 0x8c, 0xc4, 0x1f, 0xe1, 0xbb, 0xf6, 0x72)),
    :AppDataDocuments       => StupidWindowsGUID(0x7be16610, 0x1f7f, 0x44ac, (0xbf, 0xf0, 0x83, 0xe1, 0x5f, 0x2f, 0xfc, 0xa1)),
    :AppDataFavorites       => StupidWindowsGUID(0x7cfbefbc, 0xde1f, 0x45aa, (0xb8, 0x43, 0xa5, 0x42, 0xac, 0x53, 0x6c, 0xc9)),
    :AppDataProgramData     => StupidWindowsGUID(0x559d40a3, 0xa036, 0x40fa, (0xaf, 0x61, 0x84, 0xcb, 0x43, 0x0a, 0x4d, 0x34)),
    :ApplicationShortcuts   => StupidWindowsGUID(0xa3918781, 0xe5f2, 0x4890, (0xb3, 0xd9, 0xa7, 0xe5, 0x43, 0x32, 0x32, 0x8c)),
    :AppsFolder             => StupidWindowsGUID(0x1e87508d, 0x89c2, 0x42f0, (0x8a, 0x7e, 0x64, 0x5a, 0x0f, 0x50, 0xca, 0x58)),
    :AppUpdates             => StupidWindowsGUID(0xa305ce99, 0xf527, 0x492b, (0x8b, 0x1a, 0x7e, 0x76, 0xfa, 0x98, 0xd6, 0xe4)),
    :CameraRoll             => StupidWindowsGUID(0xab5fb87b, 0x7ce2, 0x4f83, (0x91, 0x5d, 0x55, 0x08, 0x46, 0xc9, 0x53, 0x7b)),
    :CameraRollLibrary      => StupidWindowsGUID(0x2b20df75, 0x1eda, 0x4039, (0x80, 0x97, 0x38, 0x79, 0x82, 0x27, 0xd5, 0xb7)),
    :CDBurning              => StupidWindowsGUID(0x9e52ab10, 0xf80d, 0x49df, (0xac, 0xb8, 0x43, 0x30, 0xf5, 0x68, 0x78, 0x55)),
    :ChangeRemovePrograms   => StupidWindowsGUID(0xdf7266ac, 0x9274, 0x4867, (0x8d, 0x55, 0x3b, 0xd6, 0x61, 0xde, 0x87, 0x2d)),
    :CommonAdminTools       => StupidWindowsGUID(0xd0384e7d, 0xbac3, 0x4797, (0x8f, 0x14, 0xcb, 0xa2, 0x29, 0xb3, 0x92, 0xb5)),
    :CommonOEMLinks         => StupidWindowsGUID(0xc1bae2d0, 0x10df, 0x4334, (0xbe, 0xdd, 0x7a, 0xa2, 0x0b, 0x22, 0x7a, 0x9d)),
    :CommonPrograms         => StupidWindowsGUID(0x0139d44e, 0x6afe, 0x49f2, (0x86, 0x90, 0x3d, 0xaf, 0xca, 0xe6, 0xff, 0xb8)),
    :CommonStartMenu        => StupidWindowsGUID(0xa4115719, 0xd62e, 0x491d, (0xaa, 0x7c, 0xe7, 0x4b, 0x8b, 0xe3, 0xb0, 0x67)),
    :CommonStartMenuPlaces  => StupidWindowsGUID(0xa440879f, 0x87a0, 0x4f7d, (0xb7, 0x00, 0x02, 0x07, 0xb9, 0x66, 0x19, 0x4A)),
    :CommonStartup          => StupidWindowsGUID(0x82A5Ea35, 0xd9cd, 0x47c5, (0x96, 0x29, 0xe1, 0x5d, 0x2f, 0x71, 0x4e, 0x6e)),
    :commonTemplates        => StupidWindowsGUID(0xB94237E7, 0x57AC, 0x4347, (0x91, 0x51, 0xB0, 0x8C, 0x6C, 0x32, 0xD1, 0xF7)),
    :ComputerFolder         => StupidWindowsGUID(0x0ac0837c, 0xbbf8, 0x452a, (0x85, 0x0d, 0x79, 0xd0, 0x8e, 0x66, 0x7c, 0xa7)),
    :ConflictFolder         => StupidWindowsGUID(0x4bfefb45, 0x347d, 0x4006, (0xa5, 0xbe, 0xac, 0x0c, 0xb0, 0x56, 0x71, 0x92)),
    :ConnectionsFolder      => StupidWindowsGUID(0x6f0cd92b, 0x2e97, 0x45d1, (0x88, 0xff, 0xb0, 0xd1, 0x86, 0xb8, 0xde, 0xdd)),
    :Contacts               => StupidWindowsGUID(0x56784854, 0xc6cb, 0x462b, (0x81, 0x69, 0x88, 0xe3, 0x50, 0xac, 0xb8, 0x82)),
    :ControlPanelFolder     => StupidWindowsGUID(0x82a74aeb, 0xaeb4, 0x465c, (0xa0, 0x14, 0xd0, 0x97, 0xee, 0x34, 0x6d, 0x63)),
    :Cookies                => StupidWindowsGUID(0x2b0f765d, 0xc0e9, 0x4171, (0x90, 0x8e, 0x08, 0xa6, 0x11, 0xb8, 0x4f, 0xf6)),
    :CurrentAppMods         => StupidWindowsGUID(0x3db40b20, 0x2a30, 0x4dbe, (0x91, 0x7e, 0x77, 0x1d, 0xd2, 0x1d, 0xd0, 0x99)),
    :Desktop                => StupidWindowsGUID(0xb4bfcc3a, 0xdb2c, 0x424c, (0xb0, 0x29, 0x7f, 0xe9, 0x9a, 0x87, 0xc6, 0x41)),
    :DevelopmentFiles       => StupidWindowsGUID(0xdbe8e08e, 0x3053, 0x4bbc, (0xb1, 0x83, 0x2a, 0x7b, 0x2b, 0x19, 0x1e, 0x59)),
    :Device                 => StupidWindowsGUID(0x1c2ac1dc, 0x4358, 0x4b6c, (0x97, 0x33, 0xaf, 0x21, 0x15, 0x65, 0x76, 0xf0)),
    :DeviceMetadataStore    => StupidWindowsGUID(0x5ce4a5e9, 0xe4eb, 0x479d, (0xb8, 0x9f, 0x13, 0x0c, 0x02, 0x88, 0x61, 0x55)),
    :Documents              => StupidWindowsGUID(0xfdd39ad0, 0x238f, 0x46af, (0xad, 0xb4, 0x6c, 0x85, 0x48, 0x03, 0x69, 0xc7)),
    :DocumentsLibrary       => StupidWindowsGUID(0x7b0db17d, 0x9cd2, 0x4a93, (0x97, 0x33, 0x46, 0xcc, 0x89, 0x02, 0x2e, 0x7c)),
    :Downloads              => StupidWindowsGUID(0x374de290, 0x123f, 0x4565, (0x91, 0x64, 0x39, 0xc4, 0x92, 0x5e, 0x46, 0x7b)),
    :Favorites              => StupidWindowsGUID(0x1777f761, 0x68ad, 0x4d8a, (0x87, 0xbd, 0x30, 0xb7, 0x59, 0xfa, 0x33, 0xdd)),
    :Fonts                  => StupidWindowsGUID(0xfd228cb7, 0xae11, 0x4ae3, (0x86, 0x4c, 0x16, 0xf3, 0x91, 0x0a, 0xb8, 0xfe)),
    :Games                  => StupidWindowsGUID(0xcac52c1a, 0xb53d, 0x4edc, (0x92, 0xd7, 0x6b, 0x2e, 0x8a, 0xc1, 0x94, 0x34)),
    :GameTasks              => StupidWindowsGUID(0x054fae61, 0x4dd8, 0x4787, (0x80, 0xb6, 0x09, 0x02, 0x20, 0xc4, 0xb7, 0x00)),
    :History                => StupidWindowsGUID(0xd9dc8a3b, 0xb784, 0x432e, (0xa7, 0x81, 0x5a, 0x11, 0x30, 0xa7, 0x59, 0x63)),
    :HomeGroup              => StupidWindowsGUID(0x52528a6b, 0xb9e3, 0x4add, (0xb6, 0x0d, 0x58, 0x8c, 0x2d, 0xba, 0x84, 0x2d)),
    :HomeGroupCurrentUser   => StupidWindowsGUID(0x9b74b6a3, 0x0dfd, 0x4f11, (0x9e, 0x78, 0x5f, 0x78, 0x00, 0xf2, 0xe7, 0x72)),
    :ImplicitAppShortcuts   => StupidWindowsGUID(0xbcb5256f, 0x79f6, 0x4cee, (0xb7, 0x25, 0xdc, 0x34, 0xe4, 0x02, 0xfd, 0x46)),
    :InternetCache          => StupidWindowsGUID(0x352481e8, 0x33be, 0x4251, (0xba, 0x85, 0x60, 0x07, 0xca, 0xed, 0xcf, 0x9d)),
    :InternetFolder         => StupidWindowsGUID(0x4d9f7874, 0x4e0c, 0x4904, (0x96, 0x7b, 0x40, 0xb0, 0xd2, 0x0c, 0x3e, 0x4b)),
    :Libraries              => StupidWindowsGUID(0x1b3ea5dc, 0xb587, 0x4786, (0xb4, 0xef, 0xbd, 0x1d, 0xc3, 0x32, 0xae, 0xae)),
    :Links                  => StupidWindowsGUID(0xbfb9d5e0, 0xc6a9, 0x404c, (0xb2, 0xb2, 0xae, 0x6d, 0xb6, 0xaf, 0x49, 0x68)),
    :LocalAppData           => StupidWindowsGUID(0xf1b32785, 0x6fba, 0x4fcf, (0x9d, 0x55, 0x7b, 0x8e, 0x7f, 0x15, 0x70, 0x91)),
    :LocalAppDataLow        => StupidWindowsGUID(0xa520a1a4, 0x1780, 0x4ff6, (0xbd, 0x18, 0x16, 0x73, 0x43, 0xc5, 0xaf, 0x16)),
    :LocalDocuments         => StupidWindowsGUID(0xf42ee2d3, 0x909f, 0x4907, (0x88, 0x71, 0x4c, 0x22, 0xfc, 0x0b, 0xf7, 0x56)),
    :LocalDownloads         => StupidWindowsGUID(0x7d83ee9b, 0x2244, 0x4e70, (0xb1, 0xf5, 0x53, 0x93, 0x04, 0x2a, 0xf1, 0xe4)),
    :LocalizedResourcesDir  => StupidWindowsGUID(0x2a00375e, 0x224c, 0x49de, (0xb8, 0xd1, 0x44, 0x0d, 0xf7, 0xef, 0x3d, 0xdc)),
    :LocalMusic             => StupidWindowsGUID(0xa0c69a99, 0x21c8, 0x4671, (0x87, 0x03, 0x79, 0x34, 0x16, 0x2f, 0xcf, 0x1d)),
    :LocalPictures          => StupidWindowsGUID(0x0ddd015d, 0xb06c, 0x45d5, (0x8c, 0x4c, 0xf5, 0x97, 0x13, 0x85, 0x46, 0x39)),
    :LocalVideos            => StupidWindowsGUID(0x35286a68, 0x3c57, 0x41a1, (0xbb, 0xb1, 0x0e, 0xae, 0x73, 0xd7, 0x6c, 0x95)),
    :Music                  => StupidWindowsGUID(0x4bd8d571, 0x6d19, 0x48d3, (0xbe, 0x97, 0x42, 0x22, 0x20, 0x08, 0x0e, 0x43)),
    :MusicLibrary           => StupidWindowsGUID(0x2112ab0a, 0xc86a, 0x4ffe, (0xa3, 0x68, 0x0d, 0xe9, 0x6e, 0x47, 0x01, 0x2e)),
    :NetHood                => StupidWindowsGUID(0xc5abbf53, 0xe17f, 0x4121, (0x89, 0x00, 0x86, 0x62, 0x6f, 0xc2, 0xc9, 0x73)),
    :NetworkFolder          => StupidWindowsGUID(0xd20beec4, 0x5ca8, 0x4905, (0xae, 0x3b, 0xbf, 0x25, 0x1e, 0xa0, 0x9b, 0x53)),
    :Objects3D              => StupidWindowsGUID(0x31c0dd25, 0x9439, 0x4f12, (0xbf, 0x41, 0x7f, 0xf4, 0xed, 0xa3, 0x87, 0x22)),
    :OneDrive               => StupidWindowsGUID(0xa52bba46, 0xe9e1, 0x435f, (0xb3, 0xd9, 0x28, 0xda, 0xa6, 0x48, 0xc0, 0xf6)),
    :OriginalImages         => StupidWindowsGUID(0x2c36c0aa, 0x5812, 0x4b87, (0xbf, 0xd0, 0x4c, 0xd0, 0xdf, 0xb1, 0x9b, 0x39)),
    :PhotoAlbums            => StupidWindowsGUID(0x69d2cf90, 0xfc33, 0x4fb7, (0x9a, 0x0c, 0xeb, 0xb0, 0xf0, 0xfc, 0xb4, 0x3c)),
    :Pictures               => StupidWindowsGUID(0x33e28130, 0x4e1e, 0x4676, (0x83, 0x5a, 0x98, 0x39, 0x5c, 0x3b, 0xc3, 0xbb)),
    :PicturesLibrary        => StupidWindowsGUID(0xa990ae9f, 0xa03b, 0x4e80, (0x94, 0xbc, 0x99, 0x12, 0xd7, 0x50, 0x41, 0x04)),
    :Playlists              => StupidWindowsGUID(0xde92c1c7, 0x837f, 0x4f69, (0xa3, 0xbb, 0x86, 0xe6, 0x31, 0x20, 0x4a, 0x23)),
    :PrintersFolder         => StupidWindowsGUID(0x76fc4e2d, 0xd6ad, 0x4519, (0xa6, 0x63, 0x37, 0xbd, 0x56, 0x06, 0x81, 0x85)),
    :PrintHood              => StupidWindowsGUID(0x9274bd8d, 0xcfd1, 0x41c3, (0xb3, 0x5e, 0xb1, 0x3f, 0x55, 0xa7, 0x58, 0xf4)),
    :Profile                => StupidWindowsGUID(0x5e6c858f, 0x0e22, 0x4760, (0x9a, 0xfe, 0xea, 0x33, 0x17, 0xb6, 0x71, 0x73)),
    :ProgramData            => StupidWindowsGUID(0x62ab5d82, 0xfdc1, 0x4dc3, (0xa9, 0xdd, 0x07, 0x0d, 0x1d, 0x49, 0x5d, 0x97)),
    :ProgramFiles           => StupidWindowsGUID(0x905e63b6, 0xc1bf, 0x494e, (0xb2, 0x9c, 0x65, 0xb7, 0x32, 0xd3, 0xd2, 0x1a)),
    :ProgramFilesCommon     => StupidWindowsGUID(0xf7f1ed05, 0x9f6d, 0x47a2, (0xaa, 0xae, 0x29, 0xd3, 0x17, 0xc6, 0xf0, 0x66)),
    :ProgramFilesCommonX64  => StupidWindowsGUID(0x6365d5a7, 0x0f0d, 0x45e5, (0x87, 0xf6, 0x0d, 0xa5, 0x6b, 0x6a, 0x4f, 0x7d)),
    :ProgramFilesCommonX86  => StupidWindowsGUID(0xde974d24, 0xd9c6, 0x4d3e, (0xbf, 0x91, 0xf4, 0x45, 0x51, 0x20, 0xb9, 0x17)),
    :ProgramFilesX64        => StupidWindowsGUID(0x6d809377, 0x6af0, 0x444b, (0x89, 0x57, 0xa3, 0x77, 0x3f, 0x02, 0x20, 0x0e)),
    :ProgramFilesX86        => StupidWindowsGUID(0x7c5a40ef, 0xa0fb, 0x4bfc, (0x87, 0x4a, 0xc0, 0xf2, 0xe0, 0xb9, 0xfa, 0x8e)),
    :Programs               => StupidWindowsGUID(0xa77f5d77, 0x2e2b, 0x44c3, (0xa6, 0xa2, 0xab, 0xa6, 0x01, 0x05, 0x4a, 0x51)),
    :Public                 => StupidWindowsGUID(0xdfdf76a2, 0xc82a, 0x4d63, (0x90, 0x6a, 0x56, 0x44, 0xac, 0x45, 0x73, 0x85)),
    :PublicDesktop          => StupidWindowsGUID(0xc4aa340d, 0xf20f, 0x4863, (0xaf, 0xef, 0xf8, 0x7e, 0xf2, 0xe6, 0xba, 0x25)),
    :PublicDocuments        => StupidWindowsGUID(0xed4824af, 0xdce4, 0x45a8, (0x81, 0xe2, 0xfc, 0x79, 0x65, 0x08, 0x36, 0x34)),
    :PublicDownloads        => StupidWindowsGUID(0x3d644c9b, 0x1fb8, 0x4f30, (0x9b, 0x45, 0xf6, 0x70, 0x23, 0x5f, 0x79, 0xc0)),
    :PublicGameTasks        => StupidWindowsGUID(0xdebf2536, 0xe1a8, 0x4c59, (0xb6, 0xa2, 0x41, 0x45, 0x86, 0x47, 0x6a, 0xea)),
    :PublicLibraries        => StupidWindowsGUID(0x48daf80b, 0xe6cf, 0x4f4e, (0xb8, 0x00, 0x0e, 0x69, 0xd8, 0x4e, 0xe3, 0x84)),
    :PublicMusic            => StupidWindowsGUID(0x3214fab5, 0x9757, 0x4298, (0xbb, 0x61, 0x92, 0xa9, 0xde, 0xaa, 0x44, 0xff)),
    :PublicPictures         => StupidWindowsGUID(0xb6ebfb86, 0x6907, 0x413c, (0x9a, 0xf7, 0x4f, 0xc2, 0xab, 0xf0, 0x7c, 0xc5)),
    :PublicRingtones        => StupidWindowsGUID(0xe555ab60, 0x153b, 0x4d17, (0x9f, 0x04, 0xa5, 0xfe, 0x99, 0xfc, 0x15, 0xec)),
    :PublicUserTiles        => StupidWindowsGUID(0x0482af6c, 0x08f1, 0x4c34, (0x8c, 0x90, 0xe1, 0x7e, 0xc9, 0x8b, 0x1e, 0x17)),
    :PublicVideos           => StupidWindowsGUID(0x2400183a, 0x6185, 0x49fb, (0xa2, 0xd8, 0x4a, 0x39, 0x2a, 0x60, 0x2b, 0xa3)),
    :QuickLaunch            => StupidWindowsGUID(0x52a4f021, 0x7b75, 0x48a9, (0x9f, 0x6b, 0x4b, 0x87, 0xa2, 0x10, 0xbc, 0x8f)),
    :Recent                 => StupidWindowsGUID(0xae50c081, 0xebd2, 0x438a, (0x86, 0x55, 0x8a, 0x09, 0x2e, 0x34, 0x98, 0x7a)),
    :RecordedCalls          => StupidWindowsGUID(0x2f8b40c2, 0x83ed, 0x48ee, (0xb3, 0x83, 0xa1, 0xf1, 0x57, 0xec, 0x6f, 0x9a)),
    :RecordedTVLibrary      => StupidWindowsGUID(0x1a6fdba2, 0xf42d, 0x4358, (0xa7, 0x98, 0xb7, 0x4d, 0x74, 0x59, 0x26, 0xc5)),
    :RecycleBinFolder       => StupidWindowsGUID(0xb7534046, 0x3ecb, 0x4c18, (0xbe, 0x4e, 0x64, 0xcd, 0x4c, 0xb7, 0xd6, 0xac)),
    :ResourceDir            => StupidWindowsGUID(0x8ad10c31, 0x2adb, 0x4296, (0xa8, 0xf7, 0xe4, 0x70, 0x12, 0x32, 0xc9, 0x72)),
    :RetailDemo             => StupidWindowsGUID(0x12d4c69e, 0x24ad, 0x4923, (0xbe, 0x19, 0x31, 0x32, 0x1c, 0x43, 0xa7, 0x67)),
    :Ringtones              => StupidWindowsGUID(0xc870044b, 0xf49e, 0x4126, (0xa9, 0xc3, 0xb5, 0x2a, 0x1f, 0xf4, 0x11, 0xe8)),
    :RoamedTileImages       => StupidWindowsGUID(0xaaa8d5a5, 0xf1d6, 0x4259, (0xba, 0xa8, 0x78, 0xe7, 0xef, 0x60, 0x83, 0x5e)),
    :RoamingAppData         => StupidWindowsGUID(0x3eb685db, 0x65f9, 0x4cf6, (0xa0, 0x3a, 0xe3, 0xef, 0x65, 0x72, 0x9f, 0x3d)),
    :RoamingTiles           => StupidWindowsGUID(0x00bcfc5a, 0xed94, 0x4e48, (0x96, 0xa1, 0x3f, 0x62, 0x17, 0xf2, 0x19, 0x90)),
    :SampleMusic            => StupidWindowsGUID(0xb250c668, 0xf57d, 0x4ee1, (0xa6, 0x3c, 0x29, 0x0e, 0xe7, 0xd1, 0xaa, 0x1f)),
    :SamplePictures         => StupidWindowsGUID(0xc4900540, 0x2379, 0x4c75, (0x84, 0x4b, 0x64, 0xe6, 0xfa, 0xf8, 0x71, 0x6b)),
    :SamplePlaylists        => StupidWindowsGUID(0x15ca69b3, 0x30ee, 0x49c1, (0xac, 0xe1, 0x6b, 0x5e, 0xc3, 0x72, 0xaf, 0xb5)),
    :SampleVideos           => StupidWindowsGUID(0x859ead94, 0x2e85, 0x48ad, (0xa7, 0x1a, 0x09, 0x69, 0xcb, 0x56, 0xa6, 0xcd)),
    :SavedGames             => StupidWindowsGUID(0x4c5c32ff, 0xbb9d, 0x43b0, (0xb5, 0xb4, 0x2d, 0x72, 0xe5, 0x4e, 0xaa, 0xa4)),
    :SavedPictures          => StupidWindowsGUID(0x3b193882, 0xd3ad, 0x4eab, (0x96, 0x5a, 0x69, 0x82, 0x9d, 0x1f, 0xb5, 0x9f)),
    :SavedPicturesLibrary   => StupidWindowsGUID(0xe25b5812, 0xbe88, 0x4bd9, (0x94, 0xb0, 0x29, 0x23, 0x34, 0x77, 0xb6, 0xc3)),
    :SavedSearches          => StupidWindowsGUID(0x7d1d3a04, 0xdebb, 0x4115, (0x95, 0xcf, 0x2f, 0x29, 0xda, 0x29, 0x20, 0xda)),
    :Screenshots            => StupidWindowsGUID(0xb7bede81, 0xdf94, 0x4682, (0xa7, 0xd8, 0x57, 0xa5, 0x26, 0x20, 0xb8, 0x6f)),
    :SearchCsc              => StupidWindowsGUID(0xee32e446, 0x31ca, 0x4aba, (0x81, 0x4f, 0xa5, 0xeb, 0xd2, 0xfd, 0x6d, 0x5e)),
    :SearchMapi             => StupidWindowsGUID(0x98ec0e18, 0x2098, 0x4d44, (0x86, 0x44, 0x66, 0x97, 0x93, 0x15, 0xa2, 0x81)),
    :SearchHistory          => StupidWindowsGUID(0x0d4c3db6, 0x03a3, 0x462f, (0xa0, 0xe6, 0x08, 0x92, 0x4c, 0x41, 0xb5, 0xd4)),
    :SearchHome             => StupidWindowsGUID(0x190337d1, 0xb8ca, 0x4121, (0xa6, 0x39, 0x6d, 0x47, 0x2d, 0x16, 0x97, 0x2a)),
    :SearchTemplates        => StupidWindowsGUID(0x7e636bfe, 0xdfa9, 0x4d5e, (0xb4, 0x56, 0xd7, 0xb3, 0x98, 0x51, 0xd8, 0xa9)),
    :SendTo                 => StupidWindowsGUID(0x8983036c, 0x27c0, 0x404b, (0x8f, 0x08, 0x10, 0x2d, 0x10, 0xdc, 0xfd, 0x74)),
    :SidebarDefaultParts    => StupidWindowsGUID(0x7b396e54, 0x9ec5, 0x4300, (0xbe, 0x0a, 0x24, 0x82, 0xeb, 0xae, 0x1a, 0x26)),
    :SidebarParts           => StupidWindowsGUID(0xa75d362e, 0x50fc, 0x4fb7, (0xac, 0x2c, 0xa8, 0xbe, 0xaa, 0x31, 0x44, 0x93)),
    :SkyDrive               => StupidWindowsGUID(0xa52bba46, 0xe9e1, 0x435f, (0xb3, 0xd9, 0x28, 0xda, 0xa6, 0x48, 0xc0, 0xf6)),
    :SkyDriveCameraRoll     => StupidWindowsGUID(0x767e6811, 0x49cb, 0x4273, (0x87, 0xc2, 0x20, 0xf3, 0x55, 0xe1, 0x08, 0x5b)),
    :SkyDriveDocuments      => StupidWindowsGUID(0x24d89e24, 0x2f19, 0x4534, (0x9d, 0xde, 0x6a, 0x66, 0x71, 0xfb, 0xb8, 0xfe)),
    :SkyDriveMusic          => StupidWindowsGUID(0xc3f2459e, 0x80d6, 0x45dc, (0xbf, 0xef, 0x1f, 0x76, 0x9f, 0x2b, 0xe7, 0x30)),
    :SkyDrivePictures       => StupidWindowsGUID(0x339719b5, 0x8c47, 0x4894, (0x94, 0xc2, 0xd8, 0xf7, 0x7a, 0xdd, 0x44, 0xa6)),
    :StartMenu              => StupidWindowsGUID(0x625b53c3, 0xab48, 0x4ec1, (0xba, 0x1f, 0xa1, 0xef, 0x41, 0x46, 0xfc, 0x19)),
    :StartMenuAllPrograms   => StupidWindowsGUID(0xf26305ef, 0x6948, 0x40b9, (0xb2, 0x55, 0x81, 0x45, 0x3d, 0x09, 0xc7, 0x85)),
    :Startup                => StupidWindowsGUID(0xb97d20bb, 0xf46a, 0x4c97, (0xba, 0x10, 0x5e, 0x36, 0x08, 0x43, 0x08, 0x54)),
    :SyncManagerFolder      => StupidWindowsGUID(0x43668bf8, 0xc14e, 0x49b2, (0x97, 0xc9, 0x74, 0x77, 0x84, 0xd7, 0x84, 0xb7)),
    :SyncResultsFolder      => StupidWindowsGUID(0x289a9a43, 0xbe44, 0x4057, (0xa4, 0x1b, 0x58, 0x7a, 0x76, 0xd7, 0xe7, 0xf9)),
    :SyncSetupFolder        => StupidWindowsGUID(0x0f214138, 0xb1d3, 0x4a90, (0xbb, 0xa9, 0x27, 0xcb, 0xc0, 0xc5, 0x38, 0x9a)),
    :System                 => StupidWindowsGUID(0x1ac14e77, 0x02e7, 0x4e5d, (0xb7, 0x44, 0x2e, 0xb1, 0xae, 0x51, 0x98, 0xb7)),
    :SystemX86              => StupidWindowsGUID(0xd65231b0, 0xb2f1, 0x4857, (0xa4, 0xce, 0xa8, 0xe7, 0xc6, 0xea, 0x7d, 0x27)),
    :Templates              => StupidWindowsGUID(0xa63293e8, 0x664e, 0x48db, (0xa0, 0x79, 0xdf, 0x75, 0x9e, 0x05, 0x09, 0xf7)),
    :UserPinned             => StupidWindowsGUID(0x9e3995ab, 0x1f9c, 0x4f13, (0xb8, 0x27, 0x48, 0xb2, 0x4b, 0x6c, 0x71, 0x74)),
    :UserProfiles           => StupidWindowsGUID(0x0762d272, 0xc50a, 0x4bb0, (0xa3, 0x82, 0x69, 0x7d, 0xcd, 0x72, 0x9b, 0x80)),
    :UserProgramFiles       => StupidWindowsGUID(0x5cd7aee2, 0x2219, 0x4a67, (0xb8, 0x5d, 0x6c, 0x9c, 0xe1, 0x56, 0x60, 0xcb)),
    :UserProgramFilesCommon => StupidWindowsGUID(0xbcbd3057, 0xca5c, 0x4622, (0xb4, 0x2d, 0xbc, 0x56, 0xdb, 0x0a, 0xe5, 0x16)),
    :UsersFiles             => StupidWindowsGUID(0xf3ce0f7c, 0x4901, 0x4acc, (0x86, 0x48, 0xd5, 0xd4, 0x4b, 0x04, 0xef, 0x8f)),
    :UsersLibraries         => StupidWindowsGUID(0xa302545d, 0xdeff, 0x464b, (0xab, 0xe8, 0x61, 0xc8, 0x64, 0x8d, 0x93, 0x9b)),
    :Videos                 => StupidWindowsGUID(0x18989b1d, 0x99b5, 0x455b, (0x84, 0x1c, 0xab, 0x7c, 0x74, 0xe4, 0xdd, 0xfc)),
    :VideosLibrary          => StupidWindowsGUID(0x491e922f, 0x5643, 0x4af4, (0xa7, 0xeb, 0x4e, 0x7a, 0x13, 0x8d, 0x81, 0x74)),
    :Windows                => StupidWindowsGUID(0xf38bf404, 0x1d43, 0x42f2, (0x93, 0x05, 0x67, 0xde, 0x0b, 0x28, 0xfc, 0x23)))

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

function knownfolder(id::Symbol)
    guid = KNOWN_FOLDER_IDS[id]
    ptr = Ref(Ptr{UInt16}())
    result =
        ccall((:SHGetKnownFolderPath, "shell32"), stdcall, UInt32,
              (StupidWindowsGUID, Cuint, Ptr{Cvoid}, Ptr{Ptr{UInt16}}),
              guid, 0, C_NULL, ptr)
    folder = if result == zero(UInt32)
        unsafe_utf16string(ptr[])
    end
    ccall((:CoTaskMemFree, "ole32.dll"), Cvoid, (Ptr{Cvoid},), ptr[])
    folder
end

function knownfolder(id::Symbol, envvars::Vector{String}, default::String)
    firstenv(envvars) =
        for envvar in envvars
            if haskey(ENV, envvar)
                return ENV[envvar]
            end
        end
    something(knownfolder(id), firstenv(envvars), default)
end

knownfolder(id::Symbol, default::String) = something(knownfolder(id), default)

const RELEVANT_FOLDERS =
    (:SystemDrive, :SystemRoot,
     :ProgramData, :Programs, :CommonPrograms,
     :UserProfiles, :RoamingAppData, :LocalAppData,
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
        :Windows, ["SystemDrive", "SystemRoot", "windir"], home) |>
            splitdrive |> first
    rf.SystemRoot = knownfolder(
        :Windows, ["SystemRoot", "windir"], joinpath(rf.SystemDrive, "Windows"))
    rf.ProgramData = knownfolder(
        :ProgramData, ["ProgramData", "ALLUSERSPROFILE"], joinpath(rf.SystemDrive, "ProgramData"))
    rf.UserProfiles = knownfolder(
        :UserProfiles, joinpath(rf.SystemDrive, "Users"))
    rf.RoamingAppData = knownfolder(
        :RoamingAppData, ["APPDATA"], joinpath(home, "AppData", "Roaming"))
    rf.LocalAppData = knownfolder(
        :LocalAppData, ["LOCALAPPDATA"], joinpath(home, "AppData", "Local"))
    rf.Desktop = knownfolder(:Desktop, joinpath(home, "Desktop"))
    rf.Downloads = knownfolder(:Downloads, joinpath(home, "Downloads"))
    rf.Documents = knownfolder(:Documents, joinpath(home, "Documents"))
    rf.Music = knownfolder(:Music, joinpath(home, "Music"))
    rf.Pictures = knownfolder(:Pictures, joinpath(home, "Pictures"))
    rf.Videos = knownfolder(:Videos, joinpath(home, "Videos"))
    rf.Templates = knownfolder(
        :Templates, joinpath(rf.RoamingAppData, "Microsoft", "Windows", "Templates"))
    rf.Public = knownfolder(:Public, ["Public"], joinpath(rf.UserProfiles, "Public"))
    rf.Fonts = knownfolder(:Fonts, joinpath(rf.SystemRoot, "Fonts"))
    rf.Programs = knownfolder(
        :Programs, joinpath(rf.RoamingAppData, "Microsoft", "Windows", "Start Menu", "Programs"))
    rf.CommonPrograms = knownfolder(
        :CommonPrograms, joinpath(rf.ProgramData, "Microsoft", "Windows", "Start Menu", "Programs"))
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
        Iterators.flatten((Iterators.filter(p -> p in path,
                                            binmaybe),
                           (pwd(),))) |> first
    end
    # User directories
    @setxdg DESKTOP_DIR rf.Desktop
    @setxdg DOWNLOAD_DIR rf.Downloads
    @setxdg DOCUMENTS_DIR rf.Documents
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

projectpath(p::Project, parent::String) =
    joinpath(projectpath(p), if parent === DATA_HOME || parent in DATA_DIRS
                 "data\\"
             elseif parent == CONFIG_HOME || parent in CONFIG_DIRS
                 "config\\"
             elseif parent == CACHE_HOME
                 "cache\\"
             elseif parent == STATE_HOME
                 "state\\"
             else
                 ""
             end)
projectpath(p::Project, parents::Vector{String}) =
    projectpath(p, first(parents))
projectpath(p::Project) = joinpath(p.org, p.name, "")
