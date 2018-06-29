import 'dart:async';
import 'dart:io';
import 'package:build/build.dart';
import 'package:build_native/src/common.dart';
import 'package:build_native/src/compiler/compiler.dart';
import 'package:build_native/src/third_party/third_party.dart';
import 'package:build_native/src/platform_type.dart';
import 'package:build_native/src/read_config.dart';
import 'package:path/path.dart' as p;

Builder libraryBuilder(BuilderOptions builderOptions) =>
    new _LibraryBuilder(builderOptions);

class _LibraryBuilder implements Builder {
  final BuilderOptions builderOptions;

  _LibraryBuilder(this.builderOptions);

  @override
  Map<String, List<String>> get buildExtensions {
    return {
      '.build_native.yaml': ['.so', '.dylib', '.dll'],
    };
  }

  @override
  Future build(BuildStep buildStep) async {
    var asset = buildStep.inputId;
    var platformType = PlatformType.thisSystem(builderOptions);
    var compiler = nativeExtensionCompilers[platformType];

    if (compiler == null) {
      throw 'Cannot compile object files on platform `${platformType
          .name}` yet.';
    }

    var config = await readConfig(asset, buildStep, platformType);

    var options = new LibraryLinkOptions(
      config,
      buildStep,
      buildStep.inputId,
      builderOptions,
      platformType,
      new DependencyManager(
        buildStep.inputId.package,
        () => buildStep.fetchResource(scratchSpaceResource),
      ),
    );
    var output = await compiler.linkLibrary(options);

    var outFile = new AssetId(
      options.inputId.package,
      p.join(
        p.dirname(options.inputId.path),
        p.setExtension(
          p.basenameWithoutExtension(
            p.basenameWithoutExtension(options.inputId.path),
          ),
          options.platformType.libraryExtension,
        ),
      ),
    );

    var bytes = await output
        .fold<BytesBuilder>(BytesBuilder(), (bb, buf) => bb..add(buf))
        .then((bb) => bb.takeBytes());
    await options.buildStep.writeAsBytes(outFile, bytes);
  }
}
