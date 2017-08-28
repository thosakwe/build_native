import 'package:build_native/build_native.dart';
import 'package:build_runner/build_runner.dart';

final PhaseGroup PHASES = new PhaseGroup.singleAction(
    new NativeExtensionBuilder(
      is64Bit: false,
    ),
    new InputSet(
      'example',
      const ['lib/*.cc'],
    ),);
