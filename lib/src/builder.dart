import 'dart:async';
import 'dart:io';
import 'package:build/build.dart';
import 'package:path/path.dart' as p;
import 'platform_type.dart';
import 'windows.dart';

class NativeExtensionBuilder implements Builder {
  String _dartLibPath, _includePath;
  bool debug;
  bool is64Bit;
  Directory sdkDir;
  WindowsBuildOptions windows;

  String get includePath => _includePath ??=
      new Directory.fromUri(sdkDir.uri.resolve('include')).absolute.path;
  String get dartLibPath => _dartLibPath ??=
      new File.fromUri(sdkDir.uri.resolve('bin/dart.lib')).absolute.path;

  NativeExtensionBuilder(
      {String sdkPath,
      this.debug: false,
      this.is64Bit: true,
      this.windows: WindowsBuildOptions.defaultOptions}) {
    if (sdkPath == null) {
      sdkDir = new File(Platform.resolvedExecutable).parent.parent;
    } else
      sdkDir = new Directory(sdkPath);
  }

  @override
  Map<String, List<String>> get buildExtensions {
    switch (PlatformType.thisSystem) {
      case PlatformType.linux:
        return {
          '.win.cc': null,
          '.cc': ['.o', '.so']
        };
      case PlatformType.windows:
        return {
          '.win.cc': null,
          '.cc': ['.dll']
        };
        break;
      case PlatformType.macOS:
        return {
          '.win.cc': null,
          // TODO: Mac support
          // '.cc': ['.o', '.so']
        };
      default:
        throw 'Unsupported OS: ${Platform.operatingSystem}';
    }
  }

  @override
  Future build(BuildStep buildStep) async {
    var asset = buildStep.inputId;
    var wDir = new File.fromUri(Directory.current.uri.resolve(asset.path))
        .parent
        .absolute
        .path; // '.'; // p.normalize(p.join(asset.path, '..'));
    print('Working dir: $wDir');
    print('Include path: $includePath');

    switch (PlatformType.thisSystem) {
      case PlatformType.linux:
        await buildLinux(asset, wDir);
        break;
      case PlatformType.windows:
        await buildWindows(asset, wDir, buildStep);
        break;
      case PlatformType.macOS:
        await buildMac(asset, wDir);
        break;
      default:
        throw new UnimplementedError(
            "Cannot build native ${PlatformType.thisSystem.name} extensions yet.");
        break;
    }
  }

  buildWindows(AssetId asset, String wDir, BuildStep buildStep) async {
    var extensionName =
        p.basenameWithoutExtension(asset.path).replaceAll('.', '_');
    var dir = new Directory(wDir);
    var assetFile = new File.fromUri(dir.uri.resolve(p.basename(asset.path)));
    var dllMainFile =
        new File.fromUri(dir.uri.resolve('${extensionName}_dllmain.win.cc'));
    var objFile = new File.fromUri(dir.uri.resolve('${extensionName}.dll'));
    await dllMainFile.writeAsString(WindowsBuildOptions.dllMain);

    try {
      // Compile via CL
      var cl = await Process.run(windows.cppCompilerPath, [
        '-I',
        includePath,
        '/DDART_SHARED_LIB',
        '/LD',
        assetFile.absolute.path,
        dllMainFile.absolute.path,
        '/link',
        '/WHOLEARCHIVE:$dartLibPath',
        '/OUT:${objFile.absolute.path}'
      ]);

      if (cl.exitCode != 0) {
        throw 'cl terminated with exit code ${cl.exitCode}: ${cl.stdout}';
      }

      var built = await objFile.readAsBytes();
      await objFile.delete();
      buildStep.writeAsBytes(asset.changeExtension('.dll'), built);
    } finally {
      await dllMainFile.delete();

      var garbage = [
        '$extensionName.exp',
        '$extensionName.lib',
        '$extensionName.obj',
        '${extensionName}_dllmain.win.obj'
      ];
      for (var g in garbage) {
        var f = new File.fromUri(Directory.current.uri.resolve(g));
        print(f.path);
        if (await f.exists()) await f.delete();
      }
    }
  }

  buildMac(AssetId asset, String wDir) async {}

  buildLinux(AssetId asset, String wDir) async {
    var filename = p.basename(asset.path);

    // Compile object code
    // g++ -fPIC -m32 -I{path to SDK include directory} -DDART_SHARED_LIB -c sample_extension.cc
    var obj = await Process.run(
        'g++',
        [
          '-fPIC',
          is64Bit ? '-m64' : '-m32',
          '-I',
          includePath,
          '-DDART_SHARED_LIB',
          '-c',
          filename
        ],
        workingDirectory: wDir);

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
    var libPath = 'lib' + p.basename(asset.changeExtension('.so').path);
    var link = await Process.run(
        'gcc',
        [
          '-shared',
          '-m32',
          '-Wl,-soname,$libPath',
          '-o',
          '$libPath',
          p.basename(asset.changeExtension('.o').path)
        ],
        workingDirectory: wDir);

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
