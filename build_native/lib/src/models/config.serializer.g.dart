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
        link: map['link'] as List<String>,
        sources: map['sources'] as List<String>,
        thirdPartyDependencies: map['third_party'] is Iterable
            ? new List.unmodifiable(((map['third_party'] as Iterable)
                    .where((x) => x is Map) as Iterable<Map>)
                .map(ThirdPartyDependencySerializer.fromMap))
            : null);
  }

  static Map<String, dynamic> toMap(BuildNativeConfig model) {
    if (model == null) {
      return null;
    }
    return {
      'flags': model.flags,
      'define': model.define,
      'link': model.link,
      'sources': model.sources,
      'third_party': model.thirdPartyDependencies
          ?.map(ThirdPartyDependencySerializer.toMap)
          ?.toList()
    };
  }
}

abstract class BuildNativeConfigFields {
  static const String flags = 'flags';

  static const String define = 'define';

  static const String link = 'link';

  static const String sources = 'sources';

  static const String thirdPartyDependencies = 'third_party';
}
