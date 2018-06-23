// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// Generator: SerializerGenerator
// **************************************************************************

abstract class BuildNativeConfigSerializer {
  static BuildNativeConfig fromMap(Map map) {
    return new BuildNativeConfig(
        flags: map['flags'],
        define: map['define'],
        link: map['link'],
        sources: map['sources']);
  }

  static Map<String, dynamic> toMap(BuildNativeConfig model) {
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
