# Build V8 Monolith Library with GitHub Actions

![Build Status](https://github.com/kuoruan/libv8/actions/workflows/v8-build-test.yml/badge.svg)
![Release Status](https://github.com/kuoruan/libv8/actions/workflows/v8-release.yml/badge.svg)
![Version Check Status](https://github.com/kuoruan/libv8/actions/workflows/v8-version-check.yml/badge.svg)


## File Structure

```
.
├── VERSION           # Current V8 version
├── archive.ps1       # Archive V8 library for Windows
├── archive.sh        # Archive V8 library for Linux and macOS
├── args
│   ├── Linux.gn      # GN args for Linux
│   ├── Windows.gn    # GN args for Windows
│   └── macOS.gn      # GN args for macOS
├── requirements.txt  # Python requirements
├── v8_compile.ps1    # Compile V8 library for Windows
├── v8_compile.sh     # Compile V8 library for Linux and macOS
├── v8_download.ps1   # Download V8 source code for Windows
├── v8_download.sh    # Download V8 source code for Linux and macOS
└── v8_test.sh        # Test V8 library for Linux and macOS
```

## Custom Version Build

- Fork this repository.
- Modify the `VERSION` file to change the V8 version.
- Commit and push to GitHub.
- Wait for the test build to complete.
- Tag the commit with the version number(prefixed with `v`) and push to GitHub.
- Wait for the release to complete.
