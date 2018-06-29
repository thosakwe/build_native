// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'third_party.dart';

// **************************************************************************
// JsonModelGenerator
// **************************************************************************

class ThirdPartyDependency extends _ThirdPartyDependency {
  ThirdPartyDependency(
      {this.webUrl,
      this.md5,
      this.gitUrl,
      this.commit,
      this.branch,
      this.tag,
      this.path,
      List<String> include,
      List<String> sources})
      : this.include = new List.unmodifiable(include ?? []),
        this.sources = new List.unmodifiable(sources ?? []);

  @override
  final String webUrl;

  @override
  final String md5;

  @override
  final String gitUrl;

  @override
  final String commit;

  @override
  final String branch;

  @override
  final String tag;

  @override
  final String path;

  @override
  final List<String> include;

  @override
  final List<String> sources;

  ThirdPartyDependency copyWith(
      {String webUrl,
      String md5,
      String gitUrl,
      String commit,
      String branch,
      String tag,
      String path,
      List<String> include,
      List<String> sources}) {
    return new ThirdPartyDependency(
        webUrl: webUrl ?? this.webUrl,
        md5: md5 ?? this.md5,
        gitUrl: gitUrl ?? this.gitUrl,
        commit: commit ?? this.commit,
        branch: branch ?? this.branch,
        tag: tag ?? this.tag,
        path: path ?? this.path,
        include: include ?? this.include,
        sources: sources ?? this.sources);
  }

  bool operator ==(other) {
    return other is _ThirdPartyDependency &&
        other.webUrl == webUrl &&
        other.md5 == md5 &&
        other.gitUrl == gitUrl &&
        other.commit == commit &&
        other.branch == branch &&
        other.tag == tag &&
        other.path == path &&
        const ListEquality<String>(const DefaultEquality<String>())
            .equals(other.include, include) &&
        const ListEquality<String>(const DefaultEquality<String>())
            .equals(other.sources, sources);
  }

  Map<String, dynamic> toJson() {
    return ThirdPartyDependencySerializer.toMap(this);
  }
}
