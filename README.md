# XDG

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://tecosaur.github.io/XDG.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://tecosaur.github.io/XDG.jl/dev/)
[![Build Status](https://github.com/tecosaur/XDG.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/tecosaur/XDG.jl/actions/workflows/CI.yml?query=branch%3Amain)

This package exists to help you *put and look for files in the appropriate place(s)*.

It is essentially an implementation of the XDG (Cross-Desktop Group) directory
specifications, with analogues for Windows and MacOS for cross-platform. More
specifically, this is a hybrid of:
- The [XDG base directory](https://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html) and the [XDG user directory](https://www.freedesktop.org/wiki/Software/xdg-user-dirs/) specifications on Linux
- The [Known Folder](https://msdn.microsoft.com/en-us/library/windows/desktop/dd378457.aspx) API on Windows
- The [Standard Directories](https://developer.apple.com/library/content/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileSystemOverview/FileSystemOverview.html#//apple_ref/doc/uid/TP40010672-CH2-SW6) guidelines on macOS

## Why should I care?

It may be easy to treat file paths haphazardly, but for the user in particular
abiding by the standards/conventions of the their platform has a number of major
benefits, such as:

- Improved ease of backups, since it is easier to make rules for which folders need to be backed up.
- Improved configuration portability, since it is easier to identify and share the relevant configuration files.
- Ease of isolating application state, by containing state to a single directory it is easy to avoid sharing it.
- Decreased reliance on hard-coded paths, improving flexibility and composability.

It is worth noting that these considerations apply to *both* graphical and
command-line desktop applications.
