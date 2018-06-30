import 'dart:async';
import 'dart:io';
import 'package:build/build.dart';
import 'package:build_native/src/common.dart';
import 'package:build_native/src/platform_type.dart';
import 'package:build_native/src/third_party/third_party.dart';
import 'package:path/path.dart' as p;
import 'package:system_info/system_info.dart';
import 'compiler.dart';

class UnixNativeExtensionCompiler implements NativeExtensionCompiler {
  const UnixNativeExtensionCompiler();

  String get defaultCC => 'gcc';

  String get defaultCXX => 'g++';

  @override
  Future<Stream<List<int>>> compileObjectFile(
      NativeCompilationOptions options) async {
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

    for (var name
        in options.config.thirdPartyDependencies?.keys ?? <String>[]) {
      var dep = options.config.thirdPartyDependencies[name];
      var toLink = options.dependencyManager
          .assumeDependencyHasAlreadyBeenDownloaded(name, dep)
          .includeDirectories;
      args.addAll(toLink.map((d) => '-I${d.absolute.path}'));
    }

    args
      ..addAll(options.compilerFlags)
      ..add(inputFile.absolute.path);

    return await execProcess(compiler, args);
  }

  @override
  Future<Stream<List<int>>> linkLibrary(
      NativeCompilationOptions options) async {
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

      if (options.platformType.canCompile(id.path)) {
        var objId = id.changeExtension(options.platformType.objectExtension);

        //if (await options.buildStep.canRead(objId)) {
        sources.add(objId);
        //}
      }
    }

    if (sources.isEmpty) {
      log.warning(
          'Either the build configuration defined no assets, or none defined were readable.');
    } else {
      var scratchSpace = await options.scratchSpace;
      //await scratchSpace.ensureAssets(sources, options.buildStep);

      for (var src in sources) {
        args.add(scratchSpace.fileFor(src).absolute.path);
      }
    }

    for (var name
        in options.config.thirdPartyDependencies?.keys ?? <String>[]) {
      var dep = options.config.thirdPartyDependencies[name];
      var view = options.dependencyManager
          .assumeDependencyHasAlreadyBeenDownloaded(name, dep);
      var toLink = view.linkDirectories;
      args.addAll(toLink.map((d) => '-L${d.absolute.path}'));

      if (view.sourceFiles.isNotEmpty) {
        var libraryFile = view.getLibraryFile(options.platformType);

        if (!await libraryFile.exists()) {
          throw 'Cannot build the extension, as the dependency `$name` failed to build.';
        }

        args.add(libraryFile.absolute.path);
      }
    }

    options.config.link?.forEach((s) => args.add('-l$s'));

    args.addAll(['-o', '/dev/stdout']);
    return await execProcess(cc, args);
  }

  @override
  Future compileDependency(
      DependencyView dependency, NativeCompilationOptions options) async {
    var cc = options.getCompilerName(defaultCC, defaultCXX);
    var outputPath =
        dependency.getLibraryFile(options.platformType).absolute.path;
    var objectPath =
        p.setExtension(outputPath, options.platformType.objectExtension);
    var args = <String>['-c', '-o', outputPath];

    for (var dir in dependency.includeDirectories) {
      args.add('-I${dir.absolute.path}');
    }

    for (var src in dependency.sourceFiles) {
      args.add(src.absolute.path);
    }

    args.addAll(dependency.linkDirectories.map((d) => '-L${d.absolute.path}'));

    await expectExitCode0(cc, args, dependency.directory.absolute.path, false);

    log.config('Output for dependency "${dependency.name}: $objectPath');

    await expectExitCode(
      'ar',
      ['rcs', p.basename(outputPath), p.basename(objectPath)],
      [0, 1],
      p.dirname(objectPath),
      false,
    );

    var outputFile = new File(outputPath);

    if (!await outputFile.exists()) {
      throw 'Successuly compiled dependency "${dependency.name}"' +
          ', but could not link it into a static library.';
    }
  }
}
