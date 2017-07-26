# build_native
Compile native extensions with `package:build`.

# Windows
Save yourself a hassle by running the build within the
`Visual Studio Developer Command Prompt`.

Regardless, executables like `cl.exe` and `link.exe` should be available.
Otherwise:

```dart
final PhaseGroup phaseGroup = new PhaseGroup.singleAction(
  new NativeExtensionBuilder(
    windows: const WindowsBuildOptions(
      cppCompilerPath: r'C:\path\to\cl.exe',
      linkerPath: r'C:\path\to\link.exe'
    )
  ),
  new InputSet('<package-name>', const ['<inputs>'])
);
```

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