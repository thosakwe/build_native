# build_native

Compile native extensions with `package:build`.

This is a 2-step build process:

1.  Build `*.{c,cc,cpp}` files to `.o`.
2.  Link files into a shared library.

Ultimately, to build everything,
you will just need to run
`pub run build_runner build`.

The goal of this package is to use *existing*
infrastructure to build native extensions.
Eventually, though, it might be nicer to
perform builds in an `after_install` script in a `pubspec.yaml`.

I've actually [submitted at PR](https://github.com/dart-lang/pub/pull/1908)
to Pub for such functionality, so instant, portable builds of
native extensions might be on their way soon.

**NOTE: Windows will soon be supported. But not yet. Beware.**

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
`<extension_name>.build_native.yaml` file
in the directory where the extension should be
built.

It should contain a list of source files to
link together.

The character `!` in a path in `sources` will be replaced
with `.obj` on Windows, and `.o` everywhere else.

The simplest example:

```yaml
sources:
  - sample_extension!
```

See `example/` for more.

All supported options:

```yaml
flags:
  - "-O2"
link:
  - sample_extension.o
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
