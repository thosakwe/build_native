import 'dart:async';
import 'dart:io';
import 'package:build_native/src/models/third_party.dart';
import 'package:build_native/src/common.dart';
import 'package:build_native/src/platform_type.dart';
import 'dependency_view.dart';
import 'external_builder.dart';

class ExternalMakefileBuilder implements ExternalBuilder {
  final bool isInBuildDirectory;

  const ExternalMakefileBuilder(this.isInBuildDirectory);

  @override
  Future build(Directory directory, ThirdPartyDependency dependency,
      DependencyView view, PlatformType platformType) {
    var args = ['-j', Platform.numberOfProcessors.toString()];

    if (dependency.target != null) {
      args.add(dependency.target);
    }

    return expectExitCode0(
      platformType == PlatformType.windows ? 'nmake' : 'make',
      args,
      (isInBuildDirectory ? view.buildDirectory : directory).absolute.path,
      false,
    );
  }
}
