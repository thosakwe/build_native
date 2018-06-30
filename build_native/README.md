# build_native
[![Pub](https://img.shields.io/pub/v/build_native.svg)](https://pub.dartlang.org/packages/build_native)
[![License](https://img.shields.io/github/license/thosakwe/build_native.svg)](https://github.com/thosakwe/build_native/blob/master/LICENSE)

Compile native extensions with `package:build`, using the system compilers.

* [About](#about)
* [Usage](#usage)
    * [Source Files](#source-files)
    * [Master Build File](#master-build-file)
* [Platform-specific Options](#platform-specific-options)
* [Third-Party Dependencies](#third-party-dependencies)
    * [Specifying a Subdirectory](#specifying-a-subdirectory)
    * [External Build Systems](#external-build-systems)
        * [Disabling Automatic Builds](#disabling-automatic-builds)
    * [From the Web](#from-the-web)
    * [From Git](#from-git)
* [Windows](#windows)
* [Unix](#unix)

**Windows building is not supported *YET*.**

# About

This is a 2-step build process:

1.  Build `*.{c,cc,cpp}` files to `.o`.
2.  Link files into a shared library.

Ultimately, to build everything and run a Dart script,
you will just need to run
`pub run build_runner run <script name>`.

The goal of this package is to use *existing*
infrastructure to build native extensions.

**As an added note, this has not been tested on Linux,
but it is developed on Mac, and the two platforms compile extensions
almost exactly the same way.**

# Usage

`build_native` requires only very little
configuration. However, this means that it
can only serve one purpose:
invoking the compiler on the user's system.

## Source Files

Also, because of the nature of `package:build`,
each input can only create one output. For
`*.c`, `*.cc`, and `*.cpp`, files, the system
compiler is invoked to create a `.o` file.
To override this, set the `CC` environment variable
when compiling C, or the `CXX` environment variable
when compiling C++.

Files named `*.macos.{c,cc,cpp}` will only build on Mac.
The same applies to `linux` and `windows`. This can be
used to apply platform-specific settings in your build.

## Master Build File

To perform linking, include an
`lib<extension_name>.build_native.yaml` file
in the directory where the extension should be
built.

It should contain a list of source files to
link together.

Note that these should all be asset ID's.

The simplest example, `libsample_extension.build_native.yaml`:

```yaml
sources:
  - example|src/sample_extension.cc
```

See `example/` for more.

All supported options:

```yaml
flags:
  - "-O2"
sources:
  - example|sample_extension.cc
  - example|sample_extension.macos.cc # Will only be included on MacOS; ignored elsewhere
link:
  - example|some_lib.o
define:
  foo: bar
  DEBUG:
```

# Platform-Specific Options

To specify options that should only apply
to a given platform, add a
`<extension_name>.<platform_name>.macos.build_native.yaml`
file,
for example,
`foo_bar.macos.build_native.yaml`.
This will be merged into the main options.

Platforms available: `macos`, `windows`, `linux`.

By providing this as the `PLATFORM` environment
variable, you can override this.

# Third-Party Dependencies
Unless you are a maniac and actually intend to write
by hand every line of C/C++ code by hand, you might eventually need to pull in
some source code from the Internet, so that it can be built alongside your program.
Specify the names of dependencies in the `third_party` section of your configuration:

```yaml
third_party:
  git: git://some/repo/here
  link:
    - lib # Directories to link against; relative paths.
  include:
    - include  # Directories to include from; relative paths.
  sources: # Source files to compile
    - src/main.c
    - src/b/c/d.c
```

## Specifying a Subdirectory
You can optionally specify a subdirectory against which to search for
[external build systems](#external-build-systems), include directories, source files,
and the like:

```yaml
third_party:
    curl:
      path: src/some/dir/where/everything/really/is
```

## External Build Systems
`package:build_native` can automatically detect configuration and build external
projects based on the following files:
* `CMakeLists.txt` - if present, triggers a CMake build on the system.
* `Makefile` - if present, triggers a GNU `make` build (`nmake` on Windows).
* `configure` - if present, it is executed via `sh`, followed by a `make` build (`nmake` on Windows).

*Note: If your aim is cross-platform builds, I personally recommend using CMake. Opting for GNU Make
can easily shut out Windows users, which many libraries might not want. (Think `node-gyp`, which has
abysmal support for Windows.)*

### Disabling Automatic Builds
In the case that you *don't* want to automatically to auto-detect build configuration in an
external project, make sure you pass a `sources` array to its configuration.

**Note: You can pass `["none"]`, and no sources will be built, as well as disabling auto-build.**

## From the Web
To require an archive from the Internet:

```yaml
third_party:
  curl:
    # All of these formats are supported:
    url: https://curl.haxx.se/download/curl-7.60.0.zip
    url: https://curl.haxx.se/download/curl-7.60.0.tar
    url: https://curl.haxx.se/download/curl-7.60.0.tar.gz
    url: https://curl.haxx.se/download/curl-7.60.0.tar.bz2
    md5: "some-hash-here" # Recommended if distributing on Pub, for security reasons.
```

## From Git
To require from Git:

```yaml
third_party:
  http_parser:
      git: https://github.com/nodejs/http-parser.git
      commit: "some-hash"
      branch: master
      tag: some tag
      path: foo/bar
      include:
        - include
      sources:
        - src/main.c
        - src/b/c/d.c
```

*Always* cloned with `--depth 1`.

# Windows

Save yourself a hassle by running the build within the
`Visual Studio Developer Command Prompt`.

Regardless, executables like `cl.exe` and `link.exe` should be available.
Otherwise:

To enable a 64-bit toolset:
https://docs.microsoft.com/en-us/cpp/build/how-to-enable-a-64-bit-visual-cpp-toolset-on-the-command-line

`vcvarsall` might be contained in:
`C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build`

# Unix

On Unix, if you some error like this:

```
fatal error: bits/c++config.h: No such file or directory
```

Then run:

```bash
sudo apt-get install -y gcc-multilib g++-multilib
```
