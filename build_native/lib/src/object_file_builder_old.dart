import 'dart:async';
import 'dart:io';
import 'package:build/build.dart';
import 'package:path/path.dart' as p;
import 'package:scratch_space/scratch_space.dart';
import 'platform_type.dart';
import 'common.dart';

Builder objectFileBuilder(BuilderOptions buildOptions) =>
    new ObjectFileBuilder(buildOptions);

class ObjectFileBuilder implements Builder {
  static const List<String> outputs = const ['.o', '.obj'];

  final BuilderOptions buildOptions;

  const ObjectFileBuilder(this.buildOptions);

  @override
  Map<String, List<String>> get buildExtensions {
    return const {
      '.c': outputs,
      '.cc': outputs,
      '.cpp': outputs,
    };
  }

  @override
  Future build(BuildStep buildStep) async {
    var asset = buildStep.inputId;
    var platform = PlatformType.thisSystem(buildOptions);
    if (!platform.canCompile(asset.path)) return null;

    var scratchSpace = await buildStep.fetchResource(scratchSpaceResource);
    await scratchSpace.ensureAssets([asset], buildStep);

    switch (platform) {
      case PlatformType.windows:
        return await buildWindows(asset, scratchSpace, buildStep);
      case PlatformType.macOS:
      case PlatformType.linux:
        return await buildUnix(asset, scratchSpace, buildStep, 'gcc', 'g++');
      default:
        throw 'Unsupported platform: $platform';
    }
  }

  Future buildUnix(AssetId asset, ScratchSpace scratchSpace, BuildStep buildStep,
      String defaultCC, String defaultCXX) async {
    var cc = Platform.environment['CC'] ?? defaultCC;
    var cxx = Platform.environment['CXX'] ?? defaultCXX;
    bool isC = p.extension(asset.path) == '.c';
    var compiler = isC ? cc : cxx;
    var flags =
        isC ? Platform.environment['CFLAGS'] : Platform.environment['CXXFLAGS'];
    var args = <String>[];
    var outAsset = asset.changeExtension('.o');
    var outFile = scratchSpace.fileFor(outAsset);

    args.addAll([
      '-c',
      '-o',
      outFile.absolute.path,
      '-I',
      includePath,
    ]);

    if (flags != null) args.addAll(flags.split(' ').where((s) => s.isNotEmpty));

    args.addAll([
      //p.setExtension(basename, '.o'),
      //p.basename(asset.path),
      scratchSpace.fileFor(asset).absolute.path,
    ]);

    var exec = '$compiler ${args.join(' ')}'.trim();
    var process = await Process.start(compiler, args);
    await handleProcess(process, exec, buildStep, scratchSpace, outAsset);
  }

  Future buildWindows(
      AssetId asset, ScratchSpace scratchSpace, BuildStep buildStep) async {
    var cc = Platform.environment['CC'] ?? 'cl';
    var cxx = Platform.environment['CXX'] ?? 'cl';
    bool isC = p.extension(asset.path) == '.c';
    var compiler = isC ? cc : cxx;
    var flags =
        isC ? Platform.environment['CFLAGS'] : Platform.environment['CXXFLAGS'];
    var args = <String>[];
    var outAsset = asset.changeExtension('.o');
    var outFile = scratchSpace.fileFor(outAsset);

    args.addAll([
      '-c',
      '-o',
      outFile.absolute.path,
      '-I',
      includePath,
    ]);

    if (flags != null) args.addAll(flags.split(' ').where((s) => s.isNotEmpty));

    args.addAll([
      //p.setExtension(basename, '.o'),
      //p.basename(asset.path),
      scratchSpace.fileFor(asset).absolute.path,
    ]);

    var exec = '$compiler ${args.join(' ')}'.trim();
    var process = await Process.start(compiler, args);
    await handleProcess(process, exec, buildStep, scratchSpace, outAsset);
  }
}
