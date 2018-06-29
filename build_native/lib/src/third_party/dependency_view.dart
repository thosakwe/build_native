import 'dart:async';
import 'dart:io';
import 'package:build_native/src/models/models.dart';
import 'package:path/path.dart' as p;
import 'external_builder.dart';

class DependencyView {
  final String name;
  final ThirdPartyDependency dependency;
  final Directory _directory;

  DependencyView(this.name, this.dependency, this._directory);

  Directory get directory {
    if (dependency.path?.isNotEmpty == true) {
      return new Directory(p.join(_directory.path, dependency.path));
    } else {
      return _directory;
    }
  }

  Future<ExternalBuilder> get externalBuilder async {
    return null;
    // TODO: Makefile, CMakeLists.txt, etc.
  }

  List<File> get sources {
    // TODO: Get sources
    return [];
  }
}
