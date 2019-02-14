import 'dart:async';
import 'dart:io';
import 'package:build_native/src/models/models.dart';
import 'package:build_native/src/platform_type.dart';
import 'dependency_view.dart';

abstract class ExternalBuilder {
  Future build(Directory directory, ThirdPartyDependency dependency,
      DependencyView view, PlatformType platformType);
}
