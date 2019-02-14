// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config.dart';

// **************************************************************************
// SerializerGenerator
// **************************************************************************

abstract class BuildNativeConfigSerializer {
  static BuildNativeConfig fromMap(Map map) {
    return new BuildNativeConfig(
        flags: map['flags'] as List<String>,
        define: map['define'] as Map<String, String>,
        include: map['include'] as List<String>,
        link: map['link'] as List<String>,
        sources: map['sources'] as List<String>,
        disallowedPlatforms: map['disallowed_platforms'] as List<String>,
        thirdPartyDependencies: map['third_party'] is Map
            ? new Map.unmodifiable(
                (map['third_party'] as Map).keys.fold({}, (out, key) {
                return out
                  ..[key] = ThirdPartyDependencySerializer.fromMap(
                      ((map['third_party'] as Map)[key]) as Map);
              }))
            : null);
  }

  static Map<String, dynamic> toMap(BuildNativeConfig model) {
    if (model == null) {
      return null;
    }
    return {
      'flags': model.flags,
      'define': model.define,
      'include': model.include,
      'link': model.link,
      'sources': model.sources,
      'disallowed_platforms': model.disallowedPlatforms,
      'third_party': model.thirdPartyDependencies.keys?.fold({}, (map, key) {
        return map
          ..[key] = ThirdPartyDependencySerializer.toMap(
              model.thirdPartyDependencies[key]);
      })
    };
  }
}

abstract class BuildNativeConfigFields {
  static const String flags = 'flags';

  static const String define = 'define';

  static const String include = 'include';

  static const String link = 'link';

  static const String sources = 'sources';

  static const String disallowedPlatforms = 'disallowed_platforms';

  static const String thirdPartyDependencies = 'third_party';
}
