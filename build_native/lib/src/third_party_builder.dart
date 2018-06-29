import 'dart:async';
import 'dart:convert';
import 'package:build/build.dart';
import 'package:build_native/src/models/models.dart';
import 'package:build_native/src/third_party/third_party.dart';
import 'package:build_native/src/common.dart';
import 'package:build_native/src/read_config.dart';
import 'package:build_native/src/platform_type.dart';

Builder thirdPartyBuilder(BuilderOptions builderOptions) =>
    new _ThirdPartyBuilder(builderOptions);

class _ThirdPartyBuilder implements Builder {
  final BuilderOptions builderOptions;

  _ThirdPartyBuilder(this.builderOptions);

  @override
  Map<String, List<String>> get buildExtensions {
    return {
      '.build_native.yaml': ['.build_native.third_party.json']
    };
  }

  @override
  Future build(BuildStep buildStep) async {
    var platformType = PlatformType.thisSystem(builderOptions);
    var manager = new DependencyManager(
      buildStep.inputId.package,
      () => buildStep.fetchResource(scratchSpaceResource),
    );

    var config = await readConfig(buildStep.inputId, buildStep, platformType);
    var deps =
        config.thirdPartyDependencies ?? <String, ThirdPartyDependency>{};

    var out = {};

    for (var name in deps.keys) {
      await manager.ensureDependency(name, deps[name], platformType);
      out[name] = manager
          .assumeDependencyHasAlreadyBeenDownloaded(name, deps[name])
          .directory
          .absolute
          .path;
    }

    buildStep.writeAsString(
      buildStep.inputId.changeExtension('.third_party.json'),
      json.encode(out),
    );
  }
}
