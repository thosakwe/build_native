import 'dart:async';
import 'package:build/build.dart';
import 'package:build_native/src/models/models.dart';
import 'package:build_native/src/platform_type.dart';
import 'package:source_span/source_span.dart';
import 'package:yaml/yaml.dart' as yaml;

String errorWithSpan(String message, SourceSpan span) {
  return '$message\n${span.highlight(color: true)}';
}

Future<BuildNativeConfig> readConfig(
    AssetId asset, AssetReader reader, PlatformType platformType) async {
  // Read the configuration file.
  var configNode = yaml.loadYamlNode(await reader.readAsString(asset));

  if (configNode is! yaml.YamlMap) {
    throw errorWithSpan('Configuration must be a map', configNode.span);
  }

  var configMap = parseConfigMap(configNode as yaml.YamlMap);
  log.config('General config: $configMap');
  var config = BuildNativeConfigSerializer.fromMap(configMap);

  if (config.disallowedPlatforms?.contains(platformType.name) == true) {
    throw 'This project has explicitly disallowed building on platform "${platformType
        .name}".';
  }

  // Try to find platform-specific config.
  var platformSpecificConfigId =
      asset.changeExtension('${platformType.name}.build_native.yaml');

  if (await reader.canRead(platformSpecificConfigId)) {
    var platformNode =
        yaml.loadYamlNode(await reader.readAsString(platformSpecificConfigId));

    if (platformNode is! yaml.YamlMap) {
      throw errorWithSpan('Configuration must be a map', platformNode.span);
    }

    var platformMap = parseConfigMap(configNode as yaml.YamlMap);
    log.config('Config for platform "${platformType.name}": $platformMap');
    var platformConfig = BuildNativeConfigSerializer.fromMap(platformMap);

    config = config.copyWith(
        define:
            new Map<String, String>.from(config.define ?? <String, String>{})
              ..addAll(platformConfig.define ?? <String, String>{}),
        flags: new List<String>.from(config.flags ?? <String>[])
          ..addAll(platformConfig.flags ?? <String>[]),
        link: new List<String>.from(config.link ?? <String>[])
          ..addAll(platformConfig.link ?? <String>[]),
        sources: new List<String>.from(config.sources ?? <String>[])
          ..addAll(platformConfig.sources ?? <String>[]),
        thirdPartyDependencies: new Map<String, ThirdPartyDependency>.from(
            config.thirdPartyDependencies ?? <String, ThirdPartyDependency>{})
          ..addAll(platformConfig.thirdPartyDependencies ??
              <String, ThirdPartyDependency>{}));

    log.config('Merged config: ${config.toJson()}');
  }

  return config;
}

Map<String, dynamic> parseConfigMap(yaml.YamlMap map) {
  var out = <String, dynamic>{};
  var thirdPartyDependencyLists = [
    BuildNativeConfigFields.thirdPartyDependencies
  ];
  var stringMaps = [BuildNativeConfigFields.define];
  var stringLists = [
    BuildNativeConfigFields.disallowedPlatforms,
    BuildNativeConfigFields.flags,
    BuildNativeConfigFields.include,
    BuildNativeConfigFields.link,
    BuildNativeConfigFields.sources
  ];

  for (var k in stringLists) {
    out[k] = unyamlifyStringList(k, map.nodes[k]) ?? <String>[];
  }

  for (var k in stringMaps) {
    out[k] = unyamlifyMap(k, map.nodes[k])?.cast<String, String>() ??
        <String, String>{};
  }

  for (var k in thirdPartyDependencyLists) {
    out[k] = parseThirdPartyDependenciesList(k, map.nodes[k]) ?? [];
  }

  return out;
}

Map<String, Map<String, dynamic>> parseThirdPartyDependenciesList(
    String key, yaml.YamlNode node) {
  var deps = unyamlifyMap(key, node);
  if (deps == null) return null;

  var map = node as yaml.YamlMap;
  var out = <String, Map<String, dynamic>>{};

  for (var k in map.nodes.keys) {
    var n = map.nodes[k];
    var v = unyamlifyMap(k.toString(), n);
    if (v != null) {
      out[k.toString()] = v;
    }
  }

  return out;
}

unyamlify(yaml.YamlNode node) {
  if (node == null) return null;
  if (node is yaml.YamlList) return unyamlifyStringList(null, node);
  if (node is yaml.YamlMap) return unyamlifyMap(null, node);
  if (node is yaml.YamlScalar) return node.value;
  throw new ArgumentError();
}

Map<String, dynamic> unyamlifyMap(String key, yaml.YamlNode node) {
  if (node == null) {
    return null;
  } else if (node is! yaml.YamlMap) {
    throw errorWithSpan('$key: expected a map', node.span);
  } else {
    var map = node as yaml.YamlMap;
    var out = <String, dynamic>{};

    for (var k in map.nodes.keys) {
      out[k.toString()] = unyamlify(map.nodes[k]);
    }

    return out;
  }
}

String unyamlifyString(String key, yaml.YamlNode node) {
  if (node == null) {
    return null;
  } else if (node is yaml.YamlScalar) {
    return node.value.toString();
  } else {
    throw errorWithSpan('$key: expected a list', node.span);
  }
}

List<String> unyamlifyStringList(String key, yaml.YamlNode node) {
  if (node == null) {
    return null;
  } else if (node is yaml.YamlScalar) {
    return [node.value.toString()];
  } else if (node is! yaml.YamlList) {
    throw errorWithSpan('$key: expected a list', node.span);
  } else {
    var list = node as yaml.YamlList;
    return list.nodes.map(unyamlify).map((x) => x.toString()).toList();
  }
}
