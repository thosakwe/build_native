import 'dart:async';
import 'dart:io';
import 'package:build_native/src/models/models.dart';
import 'package:build_native/src/platform_type.dart';
import 'package:path/path.dart' as p;
import 'package:scratch_space/scratch_space.dart';
import 'dependency.dart';
import 'dependency_view.dart';

class DependencyManager {
  final Directory directory =
      new Directory(p.join('.dart_tool', 'build_native', 'third_party'));
  final String package;
  final Future<ScratchSpace> Function() getScratchSpace;

  DependencyManager(this.package, this.getScratchSpace);

  Directory directoryFor(String name) {
    return new Directory(p.join(directory.path, '$package.$name'));
  }

  Directory buildDirectoryFor(String name) {
    var buildDir =
        p.canonicalize(p.join(directory.path, '..', 'third_party_build'));
    return new Directory(p.join(buildDir, '$package.$name'));
  }

  DependencyView assumeDependencyHasAlreadyBeenDownloaded(
      String name, ThirdPartyDependency dependency) {
    return new DependencyView(
        name, dependency, directoryFor(name), buildDirectoryFor(name), false);
  }

  Future<DependencyView> ensureDependency(String name,
      ThirdPartyDependency dependency, PlatformType platformType) async {
    var dir = directoryFor(name);
    var updater = DependencyUpdater.updaterFor(name, dependency);
    var needsRebuild = false;

    try {
      if (!await dir.exists()) {
        await updater.download(true, dependency, dir, getScratchSpace);
        needsRebuild = true;
      } else {
        var outdated = await updater.isOutdated(dependency, dir);

        if (outdated) {
          await updater.download(false, dependency, dir, getScratchSpace);
          needsRebuild = true;
        }
      }

      var view = new DependencyView(
          name, dependency, dir, buildDirectoryFor(name), needsRebuild);

      if (needsRebuild) {
        var externalBuilder = await view.getExternalBuilder(platformType);

        if (externalBuilder != null) {
          await view.buildDirectory.create(recursive: true);
          await externalBuilder.build(
              view.directory, dependency, view, platformType);
        }
      }

      return view;
    } catch (_) {
      //if (await dir.exists()) await dir.delete(recursive: true);
      rethrow;
    }
  }
}
