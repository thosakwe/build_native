# 0.0.9+11
* Cover a case where file modes in an archive are `null`.

# 0.0.9+10
* Fix decoding of `.lz`/`.xz`.

# 0.0.9+9
* Resolve third party `link` directories against the build directory.

# 0.0.9+8
* Don't build shared libraries to `/dev/stdout`, but to a file instead.

# 0.0.9+7
* Allow malformed UTF8 sequences.

# 0.0.9+6
* Patch a bug in how 3rd-party dependencies with `sources` were
compiled.

# 0.0.9+5
* Support `autoconf`, and check for it in `doctor`.
* Check for `cmake`.
* When using `libraries` from a 3rd-party dependency, pass the library's directory as an `-L` flag.

# 0.0.9+4
* Build external dependencies into a separate `third_party_build`
dir.

# 0.0.9+3
* `644` => `420` in decimal...

# 0.0.9+2
* Only `chmod` files without mode `644`.
* Support SHA1 hashes.

# 0.0.9+1
* Re-enable builder.

# 0.0.9
* Use C++ 11 on Unix systems.
* Support decompression of `.xz` and `.lz` via `package:lzma`.
* Support SHA256 checksum verification.

# 0.0.8
* Use `otool` and `install_name_tool` to ensure that output
libraries on MacOS know where to find dependencies.

# 0.0.7+6
* Fix a bug in which third-party includes were not processed.

# 0.0.7+5
* Don't manually `git checkout` if no branch/tag/commit is specified.
* Change third_party deps from `package|x` -> `package.x`; this seems to appease CMake.

# 0.0.7+4
* Log *every* program execution in `[CONFIG]`.

# 0.0.7+3
* Fix a small bug in how platform-specific options were discovered.

# 0.0.7+2
* `thirdPartyBuilder` and `libraryBuilder` should only access the
*master* build file.

# 0.0.7+1
* Errors in `doctor` should print in `red`!

# 0.0.7
* Added command-line utilities, for an easier experience.

# 0.0.6
* Allow third-party libraries with `sources` to build their own
static libraries.
* Allow linking against the outputs of other packages.
* Allow including headers from other packages.
* Allow projects to explicitly disallow platforms.

# 0.0.5
* Update the README, etc. to reflect on the fact that we are no longer
using CMake.
* Added the `thirdPartyBuilder`, which enables users to pull
in external sources.
* Enabled includes and linking against third_party dependencies.

# 0.0.4
* Return to using the user's system to build object files. Hooray for incremental builds!
* Split out object file-building functionality into a *much* cleaner API.

# 0.0.3
* Update SDK constraints, dependencies, etc., to ensure the package
installs!
* Finalize decision to build to cache.

# 0.0.2
* Use `scratch_space` to deal with temp files.
* Split into `build_native` and `example`.
* Use CMake.

# 0.0.1
* Build individual object files separately.
* Use a config-based approach to link libraries.
* Windows support is now broken, but will be added again
soon.
