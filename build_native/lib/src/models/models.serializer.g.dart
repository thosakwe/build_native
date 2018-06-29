// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// SerializerGenerator
// **************************************************************************

abstract class BuildNativeConfigSerializer {
  static BuildNativeConfig fromMap(Map map) {
    return new BuildNativeConfig(
        flags: map['flags'] as List<Object>,
        define: map['define'] as Map<Object, Object>,
        link: map['link'] as List<Object>,
        sources: map['sources'] as List<Object>);
  }

  static Map<String, dynamic> toMap(BuildNativeConfig model) {
    if (model == null) {
      return null;
    }
    return {
      'flags': model.flags,
      'define': model.define,
      'link': model.link,
      'sources': model.sources
    };
  }
}

abstract class BuildNativeConfigFields {
  static const String flags = 'flags';

  static const String define = 'define';

  static const String link = 'link';

  static const String sources = 'sources';
}
