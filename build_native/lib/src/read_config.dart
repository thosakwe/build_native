import 'dart:async';
import 'package:build/build.dart';
import 'package:build_native/src/models/models.dart';
import 'package:build_native/src/platform_type.dart';
import 'package:source_span/source_span.dart';
import 'package:yaml/yaml.dart' as yaml;

String errorWithSpan(String message, FileSpan span) {
  return '$message\n${span.highlight(color: true)}';
}

Future<BuildNativeConfig> readConfig(
    AssetId asset, AssetReader reader, PlatformType platformType) async {
  // Read the configuration file.
  var configNode = yaml.loadYamlNode(await reader.readAsString(asset));

  if (configNode is! yaml.YamlMap) {
    throw errorWithSpan('Configuration must be a map', configNode.span);
  }

  var config = BuildNativeConfigSerializer.fromMap(
      (configNode as yaml.YamlMap).cast<String, dynamic>());

  // Try to find platform-specific config.
  var platformSpecificConfigId =
      asset.changeExtension('${platformType.name}.build_native.yaml');

  if (await reader.canRead(platformSpecificConfigId)) {
    var loadedYaml =
        yaml.loadYaml(await reader.readAsString(platformSpecificConfigId));
    var specific = BuildNativeConfigSerializer.fromMap(loadedYaml);
    config = config.copyWith(
      define: new Map.from(config.define ?? {})..addAll(specific.define ?? {}),
      flags: new List.from(config.flags ?? [])..addAll(specific.flags ?? []),
      link: new List.from(config.link ?? [])..addAll(specific.link ?? []),
      sources: new List.from(config.sources ?? [])
        ..addAll(specific.sources ?? []),
    );
  }

  return config;
}
