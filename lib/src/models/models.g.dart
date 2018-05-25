// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// Generator: JsonModelGenerator
// **************************************************************************

class BuildNativeConfig extends _BuildNativeConfig {
  BuildNativeConfig(
      {List<String> flags,
      Map<String, String> define,
      List<String> link,
      List<String> sources})
      : this.flags = new List.unmodifiable(flags ?? []),
        this.define = new Map.unmodifiable(define ?? {}),
        this.link = new List.unmodifiable(link ?? []),
        this.sources = new List.unmodifiable(sources ?? []);

  @override
  final List<String> flags;

  @override
  final Map<String, String> define;

  @override
  final List<String> link;

  @override
  final List<String> sources;

  BuildNativeConfig copyWith(
      {List<String> flags,
      Map<String, String> define,
      List<String> link,
      List<String> sources}) {
    return new BuildNativeConfig(
        flags: flags ?? this.flags,
        define: define ?? this.define,
        link: link ?? this.link,
        sources: sources ?? this.sources);
  }

  bool operator ==(other) {
    return other is _BuildNativeConfig &&
        const ListEquality<String>(const DefaultEquality<String>())
            .equals(other.flags, flags) &&
        const MapEquality<String, String>(
                keys: const DefaultEquality<String>(),
                values: const DefaultEquality<String>())
            .equals(other.define, define) &&
        const ListEquality<String>(const DefaultEquality<String>())
            .equals(other.link, link) &&
        const ListEquality<String>(const DefaultEquality<String>())
            .equals(other.sources, sources);
  }

  Map<String, dynamic> toJson() {
    return BuildNativeConfigSerializer.toMap(this);
  }
}
