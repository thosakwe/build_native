# build_native
[![Pub](https://img.shields.io/pub/v/build_native.svg)](https://pub.dartlang.org/packages/build_native)
[![License](https://img.shields.io/github/license/thosakwe/build_native.svg)](https://github.com/thosakwe/build_native/blob/master/LICENSE)

Compile native extensions with `package:build`, via CMake.

This is a 2-step build process:

1.  Build `*.{c,cc,cpp}` files to `.o`.
2.  Link files into a shared library.

Ultimately, to build everything,
you will just need to run
`pub run build_runner build --output=build/vm`.

The goal of this package is to use *existing*
infrastructure to build native extensions.

**Note that at the time of this writing, it is NECESSARY
to provide an `--output` argument to the `build_runner` command;
otherwise, native extensions cannot be resolved to their correct
paths.**

**As an added note, Windows building is not supported *YET*.**

**As yet another note, this has not been tested on Linux,
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
