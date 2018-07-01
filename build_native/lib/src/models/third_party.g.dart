// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'third_party.dart';

// **************************************************************************
// JsonModelGenerator
// **************************************************************************

class ThirdPartyDependency extends _ThirdPartyDependency {
  ThirdPartyDependency(
      {this.webUrl,
      this.md5,
      this.sha256,
      this.gitUrl,
      this.commit,
      this.branch,
      this.tag,
      this.target,
      this.remote,
      this.path,
      List<String> libPaths,
      List<String> include,
      List<String> link,
      List<String> sources})
      : this.libPaths = new List.unmodifiable(libPaths ?? []),
        this.include = new List.unmodifiable(include ?? []),
        this.link = new List.unmodifiable(link ?? []),
        this.sources = new List.unmodifiable(sources ?? []);

  @override
  final String webUrl;

  @override
  final String md5;

  @override
  final String sha256;

  @override
  final String gitUrl;

  @override
  final String commit;

  @override
  final String branch;

  @override
  final String tag;

  @override
  final String target;

  @override
  final String remote;

  @override
  final String path;

  @override
  final List<String> libPaths;

  @override
  final List<String> include;

  @override
  final List<String> link;

  @override
  final List<String> sources;

  ThirdPartyDependency copyWith(
      {String webUrl,
      String md5,
      String sha256,
      String gitUrl,
      String commit,
      String branch,
      String tag,
      String target,
      String remote,
      String path,
      List<String> libPaths,
      List<String> include,
      List<String> link,
      List<String> sources}) {
    return new ThirdPartyDependency(
        webUrl: webUrl ?? this.webUrl,
        md5: md5 ?? this.md5,
        sha256: sha256 ?? this.sha256,
        gitUrl: gitUrl ?? this.gitUrl,
        commit: commit ?? this.commit,
        branch: branch ?? this.branch,
        tag: tag ?? this.tag,
        target: target ?? this.target,
        remote: remote ?? this.remote,
        path: path ?? this.path,
        libPaths: libPaths ?? this.libPaths,
        include: include ?? this.include,
        link: link ?? this.link,
        sources: sources ?? this.sources);
  }

  bool operator ==(other) {
    return other is _ThirdPartyDependency &&
        other.webUrl == webUrl &&
        other.md5 == md5 &&
        other.sha256 == sha256 &&
        other.gitUrl == gitUrl &&
        other.commit == commit &&
        other.branch == branch &&
        other.tag == tag &&
        other.target == target &&
        other.remote == remote &&
        other.path == path &&
        const ListEquality<String>(const DefaultEquality<String>())
            .equals(other.libPaths, libPaths) &&
        const ListEquality<String>(const DefaultEquality<String>())
            .equals(other.include, include) &&
        const ListEquality<String>(const DefaultEquality<String>())
            .equals(other.link, link) &&
        const ListEquality<String>(const DefaultEquality<String>())
            .equals(other.sources, sources);
  }

  Map<String, dynamic> toJson() {
    return ThirdPartyDependencySerializer.toMap(this);
  }
}
