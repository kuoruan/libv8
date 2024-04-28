# Build V8 Monolith Library with GitHub Actions

![Build Status](https://github.com/kuoruan/libv8/actions/workflows/v8-build-test.yml/badge.svg)
![Release Status](https://github.com/kuoruan/libv8/actions/workflows/v8-release.yml/badge.svg)
![Version Check Status](https://github.com/kuoruan/libv8/actions/workflows/v8-version-check.yml/badge.svg)


## File Structure

```
.
├── VERSION           # Current V8 version
├── archive.bat       # Archive V8 library for Windows
├── archive.sh        # Archive V8 library for Linux and macOS
├── args
│   ├── Linux.gn      # GN args for Linux
│   ├── Windows.gn    # GN args for Windows
│   └── macOS.gn      # GN args for macOS
├── requirements.txt  # Python requirements
├── v8_compile.bat    # Compile V8 library for Windows
├── v8_compile.sh     # Compile V8 library for Linux and macOS
├── v8_download.bat   # Download V8 source code for Windows
├── v8_download.sh    # Download V8 source code for Linux and macOS
├── v8_test.bat       # Test V8 library for Windows
└── v8_test.sh        # Test V8 library for Linux and macOS
```

## Custom Version Build

- Fork this repository.
- Modify the `VERSION` file to change the V8 version. (All versions can be found [here](https://chromium.googlesource.com/v8/v8.git/+refs))
- Commit and push to GitHub.
- Wait for the test build to complete.
- Tag the commit with the version number(prefixed with `v`) and push to GitHub.
- Wait for the release to complete.

### Build Old Versions

**Note**: Usually, we can only build the versions within the last year.

 - The old versions may not be compatible with the latest tools.
 - The old versions may require old version of toolchains, which may not be available in the latest systems.

If you want to build an old version, you may need to modify the build scripts and use the old version of `depot_tools` and other tools.

### Find the Match `depot_tools` Version

You can find the match `depot_tools` version for the V8 version in the `DEPS` file in the V8 source code.

For example, the `depot_tools` version for V8 version `10.6.1` is git revision: `0ba2fd429dd6db431fcbee6995c1278d2a3657a0`.

So you can use the following command to checkout the target `depot_tools` version:

```bash
# make sure you have `git` installed
git submodule update --init

cd depot_tools
git checkout 0ba2fd429dd6db431fcbee6995c1278d2a3657a0
```

### Find the Match `python` Version

The `depot_tools` may require a specific version of `python`. You can find the required version in the `depot_tools` README file.

### Modify the Build Scripts

The `gclient`, `gn`, `ninja` and other tools may have different arguments or behaviors in the old versions.

The `v8_download`, `v8_compile` as well as other scripts may need to be modified.
