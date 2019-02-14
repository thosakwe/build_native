import 'dart:async';
import 'dart:io';
import 'package:build_native/src/models/models.dart';
import 'package:scratch_space/scratch_space.dart';
import 'git_dependency.dart';
import 'url_dependency.dart';

abstract class DependencyUpdater {
  static DependencyUpdater updaterFor(
      String name, ThirdPartyDependency dependency) {
    if (dependency.isGit) {
      return const GitDependencyUpdater();
    } else if (dependency.isWeb) {
      return const WebDependencyUpdater();
    } else {
      throw 'Third-party dependency "$name" is missing both `git` and `url`.';
    }
  }

  Future<bool> isOutdated(ThirdPartyDependency dependency, Directory directory);

  Future download(bool isFresh, ThirdPartyDependency dependency,
      Directory directory, Future<ScratchSpace> Function() getScratchSpace);
}
