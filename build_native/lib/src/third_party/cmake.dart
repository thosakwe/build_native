import 'dart:async';
import 'dart:io';
import 'package:build_native/src/models/third_party.dart';
import 'package:build_native/src/common.dart';
import 'package:build_native/src/platform_type.dart';
import 'dependency_view.dart';
import 'external_builder.dart';

class ExternalCMakeBuilder implements ExternalBuilder {
  const ExternalCMakeBuilder();

  @override
  Future build(Directory directory, ThirdPartyDependency dependency,
      DependencyView view, PlatformType platformType) async {
    // Build the cache.
    await expectExitCode0(
      'cmake',
      [directory.absolute.path],
      view.buildDirectory.absolute.path,
      false,
    );

    // Actually build it!
    var args = ['--build', '.', '--target', dependency.target ?? 'all'];

    if (platformType != PlatformType.windows) {
      args.addAll(['--', '-j', Platform.numberOfProcessors.toString()]);
    }

    await expectExitCode0(
        'cmake', args, view.buildDirectory.absolute.path, false);
  }
}
