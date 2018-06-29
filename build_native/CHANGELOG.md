# 0.0.5
* Update the README, etc. to reflect on the fact that we are no longer
using CMake.
* Added the `thirdPartyBuilder`, which enables users to pull
in external sources.

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