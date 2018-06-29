import 'dart:async';
import 'dart:io';
import 'package:build/build.dart';
import 'package:build_native/src/common.dart';
import 'package:build_native/src/platform_type.dart';
import 'package:system_info/system_info.dart';
import 'compiler.dart';

class UnixNativeExtensionCompiler implements NativeExtensionCompiler {
  const UnixNativeExtensionCompiler();

  String get defaultCC => 'gcc';

  String get defaultCXX => 'g++';

  @override
  Future<Stream<List<int>>> compileObjectFile(
      ObjectFileCompilationOptions options) async {
    var compiler = options.getCompilerName(defaultCC, defaultCXX);
    var args = <String>[];
    var scratchSpace = await options.scratchSpace;
    var inputFile = scratchSpace.fileFor(options.inputId);
    await scratchSpace.ensureAssets([options.inputId], options.buildStep);

    args
      ..addAll([
        '-c',
        '-o',
        '/dev/stdout',
        '-I',
        includePath,
      ]);

    // TODO: Add all third-party includes.

    args
      ..addAll(options.compilerFlags)
      ..add(inputFile.absolute.path);

    return await execProcess(compiler, args);
  }

  @override
  Future<Stream<List<int>>> linkLibrary(LibraryLinkOptions options) async {
    var cc = options.getCompilerName(defaultCC, defaultCXX);

    var args = ['-shared', '-DDART_SHARED_LIB', '-o', '/dev/stdout'];
    //var basename =
    //    p.basenameWithoutExtension(p.basenameWithoutExtension(asset.path));

    if (options.platformType == PlatformType.linux) {
      args.addAll([
        //'-Wl,-soname,$libname',
        '-fPIC',
        SysInfo.userSpaceBitness == 64 ? '-m64' : '-m32'
      ]);
    } else if (options.platformType == PlatformType.macOS) {
      args.addAll(['-undefined', 'dynamic_lookup']);
    }

    options.config.define?.forEach((key, value) {
      if (value = null)
        args.add('-D$key');
      else
        args.add('-D$key=$value');
    });

    if (Platform.environment['LDFLAGS'] != null)
      args.addAll(Platform.environment['LDFLAGS']
          .split(' ')
          .where((s) => s.isNotEmpty));
    else
      args.addAll(options.config.flags?.cast<String>() ?? []);

    var sources = <AssetId>[];

    for (var src in options.config.sources ?? []) {
      var id = AssetId.parse(src.toString());
      var objId = id.changeExtension(options.platformType.objectExtension);

      if (await options.buildStep.canRead(objId)) {
        sources.add(objId);
      }
    }

    if (sources.isEmpty) {
      log.warning(
          'Either the build configuration defined no assets, or none defined were readable.');
    } else {
      var scratchSpace = await options.scratchSpace;
      await scratchSpace.ensureAssets(sources, options.buildStep);

      for (var src in sources) {
        args.add(scratchSpace.fileFor(src).absolute.path);
      }
    }

    for (var name in options.config.thirdPartyDependencies.keys) {
      var dep = options.config.thirdPartyDependencies[name];
      var toLink = options.dependencyManager
          .assumeDependencyHasAlreadyBeenDownloaded(name, dep)
          .linkDirectories;
      args.addAll(toLink.map((d) => '-L${d.absolute.path}'));
    }

    options.config.link?.forEach((s) => args.add('-l$s'));

    args.addAll(['-o', '/dev/stdout']);
    return await execProcess(cc, args);
  }
}
