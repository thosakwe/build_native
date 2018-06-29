import 'dart:async';
import 'dart:io';
import 'package:build_native/src/models/third_party.dart';
import 'package:build_native/src/common.dart';
import 'package:build_native/src/platform_type.dart';
import 'external_builder.dart';
import 'make.dart';

class ConfigureScriptBuilder implements ExternalBuilder {
  const ConfigureScriptBuilder();

  @override
  Future build(Directory directory, ThirdPartyDependency dependency,
      PlatformType platformType) async {
    await expectExitCode0(
      'sh',
      ['./configure'],// '--prefix=${directory.absolute.path}'],
      directory.absolute.path,
      false,
    );

    await const ExternalMakefileBuilder()
        .build(directory, dependency, platformType);
  }
}
