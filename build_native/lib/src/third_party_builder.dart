import 'dart:async';
import 'dart:convert';
import 'package:build/build.dart';
import 'package:build_native/src/compiler/compiler.dart';
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
    var options = new NativeCompilationOptions(
      config,
      buildStep,
      buildStep.inputId,
      builderOptions,
      platformType,
      new DependencyManager(
        buildStep.inputId.package,
        () => buildStep.fetchResource(scratchSpaceResource),
      ),
    );

    for (var name in deps.keys) {
      var dep = await manager.ensureDependency(name, deps[name], platformType);
      out[name] = manager
          .assumeDependencyHasAlreadyBeenDownloaded(name, deps[name])
          .directory
          .absolute
          .path;

      // If we just updated this library, then we should (re)build it.
      if (dep.wasJustUpdated && dep.sourceFiles.isNotEmpty) {
        var compiler = nativeExtensionCompilers[platformType];

        if (compiler == null) {
          throw 'Cannot compile external libraries on platform `${platformType
              .name}` yet.';
        }

        log.info('Compiling static library `${dep.name}`...');
        try {
          await compiler.compileDependency(dep, options);
        } catch (_) {
          //await dep.delete();
          rethrow;
        }
      }
    }

    buildStep.writeAsString(
      buildStep.inputId.changeExtension('.third_party.json'),
      json.encode(out),
    );
  }
}
