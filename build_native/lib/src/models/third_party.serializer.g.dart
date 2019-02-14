// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'third_party.dart';

// **************************************************************************
// SerializerGenerator
// **************************************************************************

abstract class ThirdPartyDependencySerializer {
  static ThirdPartyDependency fromMap(Map map) {
    return new ThirdPartyDependency(
        webUrl: map['url'] as String,
        md5: map['md5'] as String,
        sha1: map['sha1'] as String,
        sha256: map['sha256'] as String,
        gitUrl: map['git'] as String,
        commit: map['commit'] as String,
        branch: map['branch'] as String,
        tag: map['tag'] as String,
        target: map['target'] as String,
        remote: map['remote'] as String,
        path: map['path'] as String,
        libPaths: map['libraries'] as List<String>,
        include: map['include'] as List<String>,
        link: map['link'] as List<String>,
        sources: map['sources'] as List<String>);
  }

  static Map<String, dynamic> toMap(ThirdPartyDependency model) {
    if (model == null) {
      return null;
    }
    return {
      'url': model.webUrl,
      'md5': model.md5,
      'sha1': model.sha1,
      'sha256': model.sha256,
      'git': model.gitUrl,
      'commit': model.commit,
      'branch': model.branch,
      'tag': model.tag,
      'target': model.target,
      'remote': model.remote,
      'path': model.path,
      'libraries': model.libPaths,
      'include': model.include,
      'link': model.link,
      'sources': model.sources
    };
  }
}

abstract class ThirdPartyDependencyFields {
  static const String webUrl = 'url';

  static const String md5 = 'md5';

  static const String sha1 = 'sha1';

  static const String sha256 = 'sha256';

  static const String gitUrl = 'git';

  static const String commit = 'commit';

  static const String branch = 'branch';

  static const String tag = 'tag';

  static const String target = 'target';

  static const String remote = 'remote';

  static const String path = 'path';

  static const String libPaths = 'libraries';

  static const String include = 'include';

  static const String link = 'link';

  static const String sources = 'sources';
}
