import 'dart:async';
import 'dart:io';
import 'package:build/build.dart';
import 'package:build_native/src/compiler/compiler.dart';
import 'package:build_native/src/platform_type.dart';

Builder objectFileBuilder(BuilderOptions builderOptions) =>
    new _ObjectFileBuilder(builderOptions);

class _ObjectFileBuilder implements Builder {
  final BuilderOptions builderOptions;

  _ObjectFileBuilder(this.builderOptions);

  @override
  Map<String, List<String>> get buildExtensions {
    return {
      '.c': ['.o', '.obj'],
      '.cc': ['.o', '.obj'],
      '.cpp': ['.o', '.obj'],
    };
  }

  @override
  Future build(BuildStep buildStep) async {
    var platformType = PlatformType.thisSystem(builderOptions);
    var compiler = nativeExtensionCompilers[platformType];

    if (compiler == null) {
      throw 'Cannot compile object files on platform `${platformType
          .name}` yet.';
    }

    // Only compile platform-specific files if they apply to the current platform.
    if (!platformType.canCompile(buildStep.inputId.path)) {
      return null;
    }

    var options = new ObjectFileCompilationOptions(
        buildStep, buildStep.inputId, builderOptions, platformType);
    var output = await compiler.compileObjectFile(options);
    var outFile =
        options.inputId.changeExtension(options.platformType.objectExtension);
    var bytes = await output
        .fold<BytesBuilder>(BytesBuilder(), (bb, buf) => bb..add(buf))
        .then((bb) => bb.takeBytes());
    await options.buildStep.writeAsBytes(outFile, bytes);
  }
}
