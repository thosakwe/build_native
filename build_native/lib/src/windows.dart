/// Provides options to build extensions on Windows.
class WindowsBuildOptions {
  /// The path to cl.exe.
  final String cppCompilerPath;

  /// The path to link.exe.
  final String linkerPath;

  static const String dllMain = '''
    // Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
    // for details. All rights reserved. Use of this source code is governed by a
    // BSD-style license that can be found in the LICENSE file.

    #if defined(_WIN32)

    #define WIN32_LEAN_AND_MEAN
    #include <windows.h>

    BOOL APIENTRY DllMain(HMODULE module,
                          DWORD  reason,
                          LPVOID reserved) {
      return true;
    }

    #endif  // defined(_WIN32)
    ''';

  /// The default Windows build options.
  static const WindowsBuildOptions defaultOptions = const WindowsBuildOptions(
      cppCompilerPath: 'cl.exe', linkerPath: 'link.exe');

  const WindowsBuildOptions({this.cppCompilerPath, this.linkerPath});
}
