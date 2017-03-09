import 'dart:async';
import 'dart:io';
import 'package:build/build.dart';
import 'package:path/path.dart' as p;

class NativeExtensionBuilder implements Builder {
  bool debug;
  bool is64Bit;
  Directory sdkDir;

  String get includePath => sdkDir.uri.resolve('./include').path;

  PlatformType get platformType {
    if (Platform.isWindows)
      return PlatformType.WINDOWS;
    else if (Platform.isMacOS)
      return PlatformType.MAC;
    else
      return PlatformType.UNIX;
  }

  NativeExtensionBuilder(
      {String sdkPath, this.debug: false, this.is64Bit: true}) {
    if (sdkPath == null) {
      sdkDir = new Directory(
          p.normalize(p.join(Platform.resolvedExecutable, '..', '..')));
    } else
      sdkDir = new Directory(sdkPath);
  }

  @override
  List<AssetId> declareOutputs(AssetId inputId) {
    if (inputId.extension != '.cc') return [];

    switch (platformType) {
      case PlatformType.UNIX:
        return [inputId.changeExtension('.o'), inputId.changeExtension('.so')];
      case PlatformType.WINDOWS:
        return [];
        break;
      case PlatformType.MAC:
        return [];
      default:
        return [];
    }
  }

  @override
  Future build(BuildStep buildStep) async {
    var asset = buildStep.inputId;

    switch (platformType) {
      case PlatformType.UNIX:
        await buildUnix(asset);
        break;
      case PlatformType.WINDOWS:
        await buildWindows(asset);
        break;
      case PlatformType.MAC:
        await buildMac(asset);
        break;
      default:
        throw new UnimplementedError(
            "Cannot build native $platformType extensions yet.");
        break;
    }
  }

  buildWindows(AssetId asset) async {}

  buildMac(AssetId asset) async {}

  buildUnix(AssetId asset) async {
    // Compile object code
    // g++ -fPIC -m32 -I{path to SDK include directory} -DDART_SHARED_LIB -c sample_extension.cc
    var obj = await Process.run('g++', [
      '-fPIC',
      is64Bit ? '-m64' : '-m32',
      '-I$includePath',
      '-DDART_SHARED_LIB',
      '-c',
      asset.path
    ]);

    if (obj.exitCode != 0) {
      stderr
        ..writeln("g++ exited with exit code ${obj.exitCode}.")
        ..writeln("stdout:")
        ..writeln(obj.stdout)
        ..writeln("stderr:")
        ..writeln(obj.stderr);

      throw new StateError('Could not compile object code from ${asset.path}.');
    }

    // Link extension
    // gcc -shared -m32 -Wl,-soname,libsample_extension.so -o
    // libsample_extension.so sample_extension.o
    var libPath = 'lib' + asset.changeExtension('.so').path;
    var link = await Process.run('gcc', [
      '-shared',
      '-m32',
      '-Wl,-soname,$libPath',
      '-o',
      '$libPath',
      asset.path
    ]);

    if (link.exitCode != 0) {
      stderr
        ..writeln("gcc exited with exit code ${link.exitCode}.")
        ..writeln("stdout:")
        ..writeln(link.stdout)
        ..writeln("stderr:")
        ..writeln(link.stderr);

      throw new StateError(
          'Could not link compiled extension from ${asset.path}.');
    }
  }
}

enum PlatformType { MAC, WINDOWS, UNIX }
