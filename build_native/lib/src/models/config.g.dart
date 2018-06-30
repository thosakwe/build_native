// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config.dart';

// **************************************************************************
// JsonModelGenerator
// **************************************************************************

class BuildNativeConfig implements _BuildNativeConfig {
  const BuildNativeConfig(
      {List<String> this.flags,
      Map<String, String> this.define,
      List<String> this.include,
      List<String> this.link,
      List<String> this.sources,
      List<String> this.disallowedPlatforms,
      Map<String, ThirdPartyDependency> this.thirdPartyDependencies});

  @override
  final List<String> flags;

  @override
  final Map<String, String> define;

  @override
  final List<String> include;

  @override
  final List<String> link;

  @override
  final List<String> sources;

  @override
  final List<String> disallowedPlatforms;

  @override
  final Map<String, ThirdPartyDependency> thirdPartyDependencies;

  BuildNativeConfig copyWith(
      {List<String> flags,
      Map<String, String> define,
      List<String> include,
      List<String> link,
      List<String> sources,
      List<String> disallowedPlatforms,
      Map<String, ThirdPartyDependency> thirdPartyDependencies}) {
    return new BuildNativeConfig(
        flags: flags ?? this.flags,
        define: define ?? this.define,
        include: include ?? this.include,
        link: link ?? this.link,
        sources: sources ?? this.sources,
        disallowedPlatforms: disallowedPlatforms ?? this.disallowedPlatforms,
        thirdPartyDependencies:
            thirdPartyDependencies ?? this.thirdPartyDependencies);
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
            .equals(other.include, include) &&
        const ListEquality<String>(const DefaultEquality<String>())
            .equals(other.link, link) &&
        const ListEquality<String>(const DefaultEquality<String>())
            .equals(other.sources, sources) &&
        const ListEquality<String>(const DefaultEquality<String>())
            .equals(other.disallowedPlatforms, disallowedPlatforms) &&
        const MapEquality<String, ThirdPartyDependency>(
                keys: const DefaultEquality<String>(),
                values: const DefaultEquality<ThirdPartyDependency>())
            .equals(other.thirdPartyDependencies, thirdPartyDependencies);
  }

  Map<String, dynamic> toJson() {
    return BuildNativeConfigSerializer.toMap(this);
  }
}
