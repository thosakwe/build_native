import 'dart:async';
import 'dart:io';
import 'package:build/build.dart';
import 'package:build_native/src/models/models.dart';
import 'package:build_native/src/platform_type.dart';
import 'package:path/path.dart' as p;
import 'cmake.dart';
import 'configure_script.dart';
import 'external_builder.dart';
import 'make.dart';

class DependencyView {
  final String name;
  final ThirdPartyDependency dependency;
  final Directory _directory;
  final Directory buildDirectory;
  final bool wasJustUpdated;

  DependencyView(this.name, this.dependency, this._directory,
      this.buildDirectory, this.wasJustUpdated);

  Directory get directory {
    if (dependency.path?.isNotEmpty == true) {
      return new Directory(p.join(_directory.path, dependency.path));
    } else {
      return _directory;
    }
  }

  File getLibraryFile(PlatformType platformType) {
    return new File(p.setExtension(p.join(buildDirectory.path, 'lib' + name),
        platformType.staticLibraryExtension));
  }

  Future<ExternalBuilder> getExternalBuilder(PlatformType platformType) async {
    if (dependency.sources?.isNotEmpty == true) {
      return null;
    } else {
      var cmakeFile = new File(p.join(directory.path, 'CMakeLists.txt'));

      if (await cmakeFile.exists()) {
        log.config('Found CMakeLists.txt: ${cmakeFile.absolute.path}');
        return const ExternalCMakeBuilder();
      }

      if (platformType != PlatformType.windows) {
        var configureFile = new File(p.join(directory.path, 'configure'));

        if (await configureFile.exists()) {
          log.config('Found configure script: ${configureFile.absolute.path}');
          return const ConfigureScriptBuilder();
        }
      }

      var makeFile = new File(p.join(directory.path, 'Makefile'));

      if (await makeFile.exists()) {
        log.config('Found Makefile: ${makeFile.absolute.path}');
        return const ExternalMakefileBuilder(false);
      }

      return null;
    }
  }

  List<Directory> get linkDirectories {
    if (dependency.link?.isNotEmpty != true) {
      return [];
    } else {
      return dependency.link
          .map((s) => new Directory(p.canonicalize(p.join(directory.path, s))))
          .toList();
    }
  }

  List<Directory> get includeDirectories {
    if (dependency.include?.isNotEmpty != true) {
      return [];
    } else {
      return dependency.include
          .map((s) => new Directory(p.canonicalize(p.join(directory.path, s))))
          .toList();
    }
  }

  List<File> get libPathFiles {
    if (dependency.libPaths?.isNotEmpty != true) {
      return [];
    } else {
      return dependency.libPaths
          .map((s) => new File(p.canonicalize(p.join(buildDirectory.path, s))))
          .toList();
    }
  }

  List<File> get sourceFiles {
    if (dependency.sources?.isNotEmpty != true) {
      return [];
    } else {
      return dependency.sources
          .where((s) => s.trim().toLowerCase() != 'none')
          .map((s) => new File(p.canonicalize(p.join(directory.path, s))))
          .toList();
    }
  }

  Future delete() async {
    log.warning('Deleting ${_directory.absolute.path}...');
    if (await _directory.exists()) await _directory.delete(recursive: true);
  }
}
