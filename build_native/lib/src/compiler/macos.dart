import 'unix.dart';

class MacOSNativeExtensionCompiler extends UnixNativeExtensionCompiler {
  const MacOSNativeExtensionCompiler();

  @override
  String get defaultCC => 'clang';

  @override
  String get defaultCXX => 'clang';
}
