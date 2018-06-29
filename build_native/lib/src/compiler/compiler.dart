import 'dart:async';
import 'dart:io';
import 'package:build/build.dart';
import 'package:build_native/src/compiler/macos.dart';
import 'package:build_native/src/compiler/unix.dart';
import 'package:build_native/src/models/models.dart';
import 'package:build_native/src/third_party/third_party.dart';
import 'package:build_native/src/common.dart';
import 'package:build_native/src/platform_type.dart';
import 'package:scratch_space/scratch_space.dart';
import 'package:path/path.dart' as p;

Map<PlatformType, NativeExtensionCompiler> nativeExtensionCompilers = {
  PlatformType.macOS: MacOSNativeExtensionCompiler(),
  PlatformType.linux: UnixNativeExtensionCompiler(),
};

abstract class NativeExtensionCompiler {
  static bool isCpp(String path) =>
      p.extension(path) == '.cc' || p.extension(path) == '.cpp';

  Future<Stream<List<int>>> compileObjectFile(NativeCompilationOptions options);

  Future<Stream<List<int>>> linkLibrary(NativeCompilationOptions options);
}

class NativeCompilationOptions {
  final BuildNativeConfig config;
  final BuildStep buildStep;
  final AssetId inputId;
  final BuilderOptions builderOptions;
  final PlatformType platformType;
  final DependencyManager dependencyManager;

  bool get isCXX => NativeExtensionCompiler.isCpp(inputId.path);

  String getCompilerName(String defaultCC, String defaultCXX) {
    if (!isCXX) {
      return Platform.environment['CC'] ?? defaultCC;
    }

    return Platform.environment['CXX'] ?? defaultCXX;
  }

  List<String> get compilerFlags {
    var value = Platform.environment[isCXX ? 'CFLAGS' : 'CXXFLAGS'];
    return value?.split(' ')?.where((s) => s.isNotEmpty)?.toList() ?? [];
  }

  Future<ScratchSpace> get scratchSpace =>
      buildStep.fetchResource(scratchSpaceResource);

  NativeCompilationOptions(this.config, this.buildStep, this.inputId,
      this.builderOptions, this.platformType, this.dependencyManager);
}
