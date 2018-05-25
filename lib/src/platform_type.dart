import 'dart:io';
import 'package:build/build.dart';

class PlatformType {
  static PlatformType _thisSystem;
  static const PlatformType windows = const PlatformType._('windows');
  static const PlatformType macOS = const PlatformType._('macos');
  static const PlatformType linux = const PlatformType._('linux');

  final String name;

  const PlatformType._(this.name);

  static PlatformType thisSystem(BuilderOptions options) {
    var configPlatform =
        Platform.environment['PLATFORM'] ?? options.config['platform'];
    if (_thisSystem != null)
      return _thisSystem;
    else if (Platform.isWindows || configPlatform == 'windows')
      return _thisSystem = windows;
    else if (Platform.isMacOS || configPlatform == 'macos')
      return _thisSystem = macOS;
    else if (Platform.isLinux || configPlatform == 'linux')
      return _thisSystem = linux;
    else
      throw 'Could not detect platform type for operating system: ${Platform.operatingSystem}';
  }
}
