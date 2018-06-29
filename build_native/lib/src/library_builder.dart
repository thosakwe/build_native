import 'dart:async';
import 'dart:io';
import 'package:build/build.dart';
import 'package:build_native/src/compiler/compiler.dart';
import 'package:build_native/src/models/models.dart';
import 'package:build_native/src/platform_type.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart' as yaml;

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

    // Read the configuration file.
    var config = BuildNativeConfigSerializer.fromMap(
        yaml.loadYaml(await buildStep.readAsString(asset)));

    // Try to find platform-specific config.
    var platformSpecificConfigId =
        asset.changeExtension('${platformType.name}.build_native.yaml');

    if (await buildStep.canRead(platformSpecificConfigId)) {
      var loadedYaml =
          yaml.loadYaml(await buildStep.readAsString(platformSpecificConfigId));
      var specific = BuildNativeConfigSerializer.fromMap(loadedYaml);
      config = config.copyWith(
        define: new Map.from(config.define ?? {})
          ..addAll(specific.define ?? {}),
        flags: new List.from(config.flags ?? [])..addAll(specific.flags ?? []),
        link: new List.from(config.link ?? [])..addAll(specific.link ?? []),
        sources: new List.from(config.sources ?? [])
          ..addAll(specific.sources ?? []),
      );
    }

    var options = new LibraryLinkOptions(
        config, buildStep, buildStep.inputId, builderOptions, platformType);
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
