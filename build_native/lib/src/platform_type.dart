import 'dart:io';
import 'package:build/build.dart';
import 'package:path/path.dart' as p;

class PlatformType {
  static PlatformType _thisSystem;
  static const PlatformType windows =
      const PlatformType._('windows', '.dll', '.lib', '.obj');
  static const PlatformType macOS =
      const PlatformType._('macos', '.dylib', '.a', '.o');
  static const PlatformType linux =
      const PlatformType._('linux', '.so', '.a', '.o');

  final String name;
  final String sharedLibraryExtension;
  final String staticLibraryExtension;
  final String objectExtension;

  const PlatformType._(this.name, this.sharedLibraryExtension,
      this.staticLibraryExtension, this.objectExtension);

  static PlatformType thisSystem(BuilderOptions builderOptions) {
    var configPlatform =
        Platform.environment['PLATFORM'] ?? builderOptions.config['platform'];
    if (_thisSystem != null)
      return _thisSystem;
    else if (Platform.isWindows || configPlatform == 'windows')
      return _thisSystem = windows;
    else if (Platform.isMacOS || configPlatform == 'macos')
      return _thisSystem = macOS;
    else if (Platform.isLinux || configPlatform == 'linux')
      return _thisSystem = linux;
    else
      throw 'Could not detect platform type for operating system: ${Platform
          .operatingSystem}';
  }

  static String basenameWithoutAnyExtension(String path) {
    return p.basenameWithoutExtension(stripPlatformExtension(path));
  }

  static String stripPlatformExtension(String path) {
    var withoutCExtension = p.basenameWithoutExtension(path);
    var remainingBasename = p.basenameWithoutExtension(withoutCExtension);
    return p.setExtension(remainingBasename, p.extension(path));
  }

  bool canCompile(String path) {
    var withoutCExtension = p.basenameWithoutExtension(path);
    var remainingExtension = p.extension(withoutCExtension);
    return remainingExtension.isEmpty || remainingExtension == '.$name';
  }
}
