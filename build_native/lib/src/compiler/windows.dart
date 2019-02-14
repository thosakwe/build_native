import 'dart:io';

import 'package:build/build.dart';
import 'package:build_native/src/common.dart';
import 'package:build_native/src/third_party/dependency_view.dart';
import 'package:path/path.dart' as p;
import 'compiler.dart';

class WindowsNativeExtensionCompiler extends NativeExtensionCompiler {
  String get defaultCC => 'cl';

  String get defaultCXX => defaultCC;

  @override
  Future<Stream<List<int>>> compileObjectFile(
      NativeCompilationOptions options) async {
    var compiler = options.getCompilerName(defaultCC, defaultCXX);
    var args = <String>[];
    var scratchSpace = await options.scratchSpace;
    var inputFile = scratchSpace.fileFor(options.inputId);
    var outputFile = scratchSpace
        .fileFor(options.inputId.changeExtension('.build_native.out.obj'));
    await scratchSpace.ensureAssets([options.inputId], options.buildStep);

    args
      ..addAll([
        '/c',
        '/out:' + outputFile.absolute.path,
        '/I',
        includePath,
      ]);

    for (var s in options.config.include ?? <String>[]) {
      try {
        var id = AssetId.parse(s);

        if (!await options.buildStep.canRead(id)) {
          throw 'Attempted to depend on the output of "$s", but it seems to have failed to build.';
        } else {
          var scratchSpace = await options.scratchSpace;
          await scratchSpace.ensureAssets([id], options.buildStep);
          args.addAll(['/I', scratchSpace.fileFor(id).absolute.path]);
        }
      } on FormatException {
        args.addAll(['/I', s]);
      }
    }

    for (var name
        in options.config.thirdPartyDependencies?.keys ?? <String>[]) {
      var dep = options.config.thirdPartyDependencies[name];
      var toLink = options.dependencyManager
          .assumeDependencyHasAlreadyBeenDownloaded(name, dep)
          .includeDirectories;
      toLink.forEach((d) => args.addAll(['/I', d.absolute.path]));
    }

    args
      ..addAll(options.compilerFlags)
      ..add(inputFile.absolute.path);

    await execProcess(compiler, args).then((s) => s.drain());
    return outputFile.openRead();
  }

  @override
  Future compileDependency(
      DependencyView dependency, NativeCompilationOptions options) async {
    var cc = options.getCompilerName(defaultCC, defaultCXX);
    var outputPath =
        dependency.getLibraryFile(options.platformType).absolute.path;
    // var libPath =
    //     p.setExtension(outputPath, options.platformType.objectExtension);
    var args = <String>['/LD', '/out:' + outputPath];

    var objectDir = new Directory(p.dirname(outputPath));
    await objectDir.create(recursive: true);

    for (var dir in dependency.includeDirectories) {
      args.addAll(['/I', dir.absolute.path]);
    }

    for (var src in dependency.sourceFiles) {
      args.add(src.absolute.path);
    }

    dependency.linkDirectories
        .forEach((d) => args.addAll(['/LIBPATH', d.absolute.path]));

    await expectExitCode0(cc, args, dependency.directory.absolute.path, false);
  }

  @override
  Future<Stream<List<int>>> linkLibrary(NativeCompilationOptions options) {
    throw UnimplementedError();
  }
}
