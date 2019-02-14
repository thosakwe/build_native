import 'dart:async';
import 'package:build/build.dart';
import 'package:build_native/src/compiler/compiler.dart';
import 'package:build_native/src/models/models.dart';
import 'package:build_native/src/third_party/third_party.dart';
import 'package:build_native/src/common.dart';
import 'package:build_native/src/platform_type.dart';

//Builder objectFileBuilder(BuilderOptions builderOptions) =>
//    new ObjectFileBuilder(builderOptions);

class ObjectFileBuilder {
  //implements Builder {
  final BuildNativeConfig config;
  final BuilderOptions builderOptions;

  ObjectFileBuilder(this.builderOptions, this.config);

  /*
  @override
  Map<String, List<String>> get buildExtensions {
    return {
      '.c': ['.o', '.obj'],
      '.cc': ['.o', '.obj'],
      '.cpp': ['.o', '.obj'],
    };
  }
  */

  //@override
  //Future build(BuildStep buildStep) async {
  Future build(AssetId asset, BuildStep buildStep) async {
    var platformType = PlatformType.thisSystem(builderOptions);
    var compiler = nativeExtensionCompilers[platformType];

    if (compiler == null) {
      throw 'Cannot compile object files on platform `${platformType.name}` yet.';
    }

    // Only compile platform-specific files if they apply to the current platform.
    if (!platformType.canCompile(asset.path)) {
      return null;
    }

    var options = new NativeCompilationOptions(
      config,
      buildStep,
      asset,
      builderOptions,
      platformType,
      new DependencyManager(
        buildStep.inputId.package,
        () => buildStep.fetchResource(scratchSpaceResource),
      ),
    );

    var output = await compiler.compileObjectFile(options);
    var outAsset =
        options.inputId.changeExtension(options.platformType.objectExtension);
//    var bytes = await output
//        .fold<BytesBuilder>(BytesBuilder(), (bb, buf) => bb..add(buf))
//        .then((bb) => bb.takeBytes());
//    await options.buildStep.writeAsBytes(outAsset, bytes);

    var ss = await options.scratchSpace;
    var outFile = ss.fileFor(outAsset);
    await outFile.create(recursive: true);
    await output.pipe(outFile.openWrite());
  }
}
