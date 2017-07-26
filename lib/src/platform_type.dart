import 'dart:io';

class PlatformType {
  static PlatformType _thisSystem;
  static const PlatformType windows = const PlatformType._('Windows');
  static const PlatformType macOS = const PlatformType._('MacOS');
  static const PlatformType linux = const PlatformType._('Linux');

  final String name;

  const PlatformType._(this.name);

  static PlatformType get thisSystem {
    if (_thisSystem != null)
      return _thisSystem;
    else if (Platform.isWindows)
      return _thisSystem = windows;
    else if (Platform.isMacOS)
      return _thisSystem = macOS;
    else if (Platform.isLinux)
      return _thisSystem = linux;
    else
      throw 'Could not detect platform type for operating system: ${Platform.operatingSystem}';
  }
}
