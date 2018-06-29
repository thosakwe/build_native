// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonModelGenerator
// **************************************************************************

class BuildNativeConfig implements _BuildNativeConfig {
  const BuildNativeConfig(
      {List<Object> this.flags,
      Map<Object, Object> this.define,
      List<Object> this.link,
      List<Object> this.sources});

  @override
  final List<Object> flags;

  @override
  final Map<Object, Object> define;

  @override
  final List<Object> link;

  @override
  final List<Object> sources;

  BuildNativeConfig copyWith(
      {List<Object> flags,
      Map<Object, Object> define,
      List<Object> link,
      List<Object> sources}) {
    return new BuildNativeConfig(
        flags: flags ?? this.flags,
        define: define ?? this.define,
        link: link ?? this.link,
        sources: sources ?? this.sources);
  }

  bool operator ==(other) {
    return other is _BuildNativeConfig &&
        const ListEquality<Object>(const DefaultEquality<Object>())
            .equals(other.flags, flags) &&
        const MapEquality<Object, Object>(
                keys: const DefaultEquality<Object>(),
                values: const DefaultEquality<Object>())
            .equals(other.define, define) &&
        const ListEquality<Object>(const DefaultEquality<Object>())
            .equals(other.link, link) &&
        const ListEquality<Object>(const DefaultEquality<Object>())
            .equals(other.sources, sources);
  }

  Map<String, dynamic> toJson() {
    return BuildNativeConfigSerializer.toMap(this);
  }
}
