import 'dart:async';
import 'dart:io';
import 'package:build_native/src/models/third_party.dart';
import 'package:build_native/src/common.dart';
import 'package:build_native/src/platform_type.dart';
import 'configure_script.dart';
import 'dependency_view.dart';
import 'external_builder.dart';

class AutoconfBuilder implements ExternalBuilder {
  const AutoconfBuilder();

  @override
  Future build(Directory directory, ThirdPartyDependency dependency,
      DependencyView view, PlatformType platformType) async {
    await expectExitCode0(
      'autoreconf',
      ['-i'],
      directory.absolute.path,
      false,
    );

    await const ConfigureScriptBuilder()
        .build(directory, dependency, view, platformType);
  }
}
