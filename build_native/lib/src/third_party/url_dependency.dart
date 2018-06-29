import 'dart:async';
import 'dart:io';
import 'package:build_native/src/models/third_party.dart';
import 'package:convert/convert.dart';
import 'package:scratch_space/scratch_space.dart';
import 'dependency.dart';

class WebDependencyUpdater implements DependencyUpdater {
  const WebDependencyUpdater();

  @override
  Future download(bool isFresh, ThirdPartyDependency dependency,
      Directory directory, Future<ScratchSpace> Function() getScratchSpace) {
    throw new UnimplementedError();
  }

  @override
  Future<bool> isOutdated(
      ThirdPartyDependency dependency, Directory directory) {
    throw new UnimplementedError();
  }
}
