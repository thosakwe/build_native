import 'dart:async';
import 'dart:io';
import 'package:build_native/src/models/third_party.dart';
import 'package:build_native/src/common.dart';
import 'package:build_native/src/platform_type.dart';
import 'package:path/path.dart' as p;
import 'dependency_view.dart';
import 'external_builder.dart';
import 'make.dart';

class ConfigureScriptBuilder implements ExternalBuilder {
  const ConfigureScriptBuilder();

  @override
  Future build(Directory directory, ThirdPartyDependency dependency,
      DependencyView view, PlatformType platformType) async {
    var configurePath =
        p.canonicalize(p.join(directory.absolute.path, 'configure'));

    await expectExitCode0(
      'sh',
      [configurePath, '--prefix=${view.buildDirectory.absolute.path}'],
      view.buildDirectory.absolute.path,
      false,
    );

    await const ExternalMakefileBuilder(true)
        .build(directory, dependency, view, platformType);
  }
}
