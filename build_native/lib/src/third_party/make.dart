import 'dart:async';
import 'dart:io';
import 'package:build_native/src/models/third_party.dart';
import 'package:build_native/src/common.dart';
import 'package:build_native/src/platform_type.dart';
import 'external_builder.dart';

class ExternalMakefileBuilder implements ExternalBuilder {
  const ExternalMakefileBuilder();

  @override
  Future build(Directory directory, ThirdPartyDependency dependency,
      PlatformType platformType) {
    var args = ['-j', Platform.numberOfProcessors.toString()];

    if (dependency.target != null) {
      args.add(dependency.target);
    }

    return expectExitCode0('make', args, directory.absolute.path, false);
  }
}
