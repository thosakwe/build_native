import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:build/build.dart';
import 'package:cli_util/cli_util.dart';
import 'package:package_resolver/package_resolver.dart';
import 'package:path/path.dart' as p;
import 'package:system_info/system_info.dart';
import 'package:yaml/yaml.dart' as yaml;
import 'models/models.dart';
import 'platform_type.dart';
import 'windows.dart';

Builder nativeExtensionCCBuilder(BuilderOptions options) =>
    new NativeExtensionBuilder(
        options.overrideWith(new BuilderOptions({'master': false})));

Builder nativeExtensionLinkBuilder(BuilderOptions options) =>
    new NativeExtensionBuilder(
        options.overrideWith(new BuilderOptions({'master': true})));

class NativeExtensionBuilder implements Builder {
  final BuilderOptions options;
  bool debug;
  bool is64Bit;
  Directory sdkDir;
  WindowsBuildOptions windows;
  String _dartLibPath, _includePath;

  String get includePath =>
      _includePath ??= p.absolute(p.join(getSdkPath(), 'include'));
  String get dartLibPath =>
      _dartLibPath ??= p.absolute(p.join(getSdkPath(), 'bin', 'dart.lib'));

  static const List<String> platformExtensions = const [
    '.windows',
    '.linux',
    '.macos'
  ];

  NativeExtensionBuilder(this.options,
      {String sdkPath,
      this.debug: false,
      this.is64Bit: true,
      this.windows: WindowsBuildOptions.defaultOptions}) {
    if (sdkPath == null) {
      sdkDir = new Directory(getSdkPath());
    } else
      sdkDir = new Directory(sdkPath);
  }

  @override
  Map<String, List<String>> get buildExtensions {
    if (options.config['master'] is! bool)
      throw 'build_native configuration missing `master` field: ${options.config}';

    if (options.config['master'] == true)
      return {
        '.build_native.yaml': const ['.build_native.log']
      };

    const List<String> outputs = const ['.o'];
    return {
      '.c': outputs,
      '.cc': outputs,
      '.cpp': outputs,
    };

    /*
    switch (platform) {
      case PlatformType.linux:
        ext
          ..['.linux.c'] =
              ext['.linux.cc'] = ext['.linux.cpp'] = const ['.linux.o'];
        break;
      case PlatformType.macOS:
        ext
          ..['.macos.c'] =
              ext['.macos.cc'] = ext['.macos.cpp'] = const ['.macos.o'];
        break;
      case PlatformType.windows:
        ext
          ..['.windows.c'] =
              ext['.windows.cc'] = ext['.windows.cpp'] = const ['.windows.o'];
        break;
    }
    */
  }

  @override
  Future build(BuildStep buildStep) async {
    var asset = buildStep.inputId;
    var packageUri = await PackageResolver.current.packagePath(asset.package);
    var baseDir = p.fromUri(packageUri);

    var parts = [baseDir];
    parts.addAll(p.split(asset.path));
    var wDir = p.dirname(p.joinAll(parts));
    log.config('Working dir: $wDir');
    log.config('Include path: $includePath');

    var platform = PlatformType.thisSystem(options);

    if (p.extension(asset.path) == '.yaml') {
      var stripped =
          p.basenameWithoutExtension(p.basenameWithoutExtension(asset.path));
      if (p.extension(stripped) != '') return;

      // Read the configuration file.
      var config = BuildNativeConfigSerializer
          .fromMap(yaml.loadYaml(await buildStep.readAsString(asset)));

      // Try to find platform-specific config.
      var id = new AssetId.resolve(
          '$stripped.${platform.name}.build_native.yaml',
          from: asset);

      if (await buildStep.canRead(id)) {
        var specific = BuildNativeConfigSerializer
            .fromMap(yaml.loadYaml(await buildStep.readAsString(id)));
        config = config.copyWith(
          define: new Map.from(config.define ?? {})
            ..addAll(specific.define ?? {}),
          flags: new List.from(config.flags ?? [])
            ..addAll(specific.flags ?? []),
          link: new List.from(config.link ?? [])..addAll(specific.link ?? []),
          sources: new List.from(config.sources ?? [])
            ..addAll(specific.sources ?? []),
        );
      }

      switch (platform) {
        case PlatformType.macOS:
          await linkUnix(asset, wDir, config, buildStep, 'clang');
          break;
        case PlatformType.linux:
          await linkUnix(asset, wDir, config, buildStep, 'gcc');
          break;
        case PlatformType.windows:
          await linkWindows(asset, wDir, config, buildStep, 'link');
          break;
        default:
          throw new UnimplementedError(
              "Cannot link native ${PlatformType.thisSystem(options).name} extensions yet.");
          break;
      }
    } else {
      switch (platform) {
        case PlatformType.linux:
          await buildUnix(asset, wDir, buildStep, 'gcc', 'g++');
          break;
        case PlatformType.windows:
          await buildWindows(asset, wDir, buildStep);
          break;
        case PlatformType.macOS:
          await buildUnix(asset, wDir, buildStep, 'clang', 'clang');
          break;
        default:
          throw new UnimplementedError(
              "Cannot build native ${PlatformType.thisSystem(options).name} extensions yet.");
          break;
      }
    }
  }

  buildUnix(AssetId asset, String wDir, BuildStep buildStep, String defaultCC,
      String defaultCXX) async {
    var cc = Platform.environment['CC'] ?? defaultCC;
    var cxx = Platform.environment['CXX'] ?? defaultCXX;
    bool isC = p.extension(asset.path) == '.c';
    var compiler = isC ? cc : cxx;
    var flags =
        isC ? Platform.environment['CFLAGS'] : Platform.environment['CXXFLAGS'];
    var args = <String>[];
    var basename = p.basenameWithoutExtension(asset.path);

    if (platformExtensions.contains(p.extension(basename))) {
      var name = p.extension(basename);
      name = name.substring(1);
      if (name != PlatformType.thisSystem(options).name) return;
      //basename = p.basenameWithoutExtension(basename);
    }

    args.addAll([
      '-c',
      '-o',
      '/dev/stdout',
      '-I',
      includePath,
    ]);

    if (flags != null) args.addAll(flags.split(' ').where((s) => s.isNotEmpty));

    args.addAll([
      //p.setExtension(basename, '.o'),
      p.basename(asset.path),
    ]);

    var exec = '$compiler ${args.join(' ')}'.trim();
    print(exec);

    var process = await Process.start(compiler, args, workingDirectory: wDir);
    await handleProcess(process, exec, buildStep, asset);
  }

  buildWindows(AssetId asset, String wDir, BuildStep buildStep) async {
    var cc = Platform.environment['CC'] ?? 'cl';
    var cxx = Platform.environment['CXX'] ?? 'cl';
    bool isC = p.extension(asset.path) == '.c';
    var compiler = isC ? cc : cxx;
    var flags =
        isC ? Platform.environment['CFLAGS'] : Platform.environment['CXXFLAGS'];
    var args = <String>[];
    var basename = p.basenameWithoutExtension(asset.path);

    if (platformExtensions.contains(p.extension(basename))) {
      var name = p.extension(basename);
      name = name.substring(1);
      if (name != PlatformType.thisSystem(options).name) return;
      //basename = p.basenameWithoutExtension(basename);
    }

    args.addAll([
      '-c',
      '-o',
      '/dev/stdout',
      '-I',
      includePath,
    ]);

    if (flags != null) args.addAll(flags.split(' ').where((s) => s.isNotEmpty));

    args.addAll([
      //p.setExtension(basename, '.o'),
      p.basename(asset.path),
    ]);

    var exec = '$compiler ${args.join(' ')}'.trim();
    print(exec);

    var process = await Process.start(compiler, args, workingDirectory: wDir);
    await handleProcess(process, exec, buildStep, asset);
  }

  Future handleProcess(
      Process process, String exec, BuildStep buildStep, AssetId asset) async {
    var code = await process.exitCode;

    if (code != 0) {
      var out = await process.stdout.transform(utf8.decoder).join();
      var err = await process.stderr.transform(utf8.decoder).join();
      if (out.isNotEmpty) log.info(out);
      if (err.isNotEmpty) log.severe(err);
      log.severe('$exec terminated with exit code $code.');
      throw '$exec terminated with exit code $code.';
    } else {
      var output = await process.stdout
          .fold(new BytesBuilder(), (b, data) => b..add(data))
          .then((bb) => bb.takeBytes());
      await process.stderr.toList();
      buildStep.writeAsBytes(asset.changeExtension('.o'), output);
    }
  }

  linkUnix(AssetId asset, String wDir, BuildNativeConfig config,
      BuildStep buildStep, String defaultCC) async {
    var cc = Platform.environment['CC'] ?? defaultCC;
    var args = ['-shared', '-DDART_SHARED_LIB', '-o', '/dev/stdout'];
    var platform = PlatformType.thisSystem(options);
    var basename =
        p.basenameWithoutExtension(p.basenameWithoutExtension(asset.path));
    var libname = 'lib' + basename;

    if (platform == PlatformType.linux) {
      libname += '.so';
      args.addAll([
        '-Wl,-soname,$libname',
        '-fPIC',
        SysInfo.userSpaceBitness == 64 ? '-m64' : '-m32'
      ]);
    } else if (platform == PlatformType.macOS) {
      libname += '.dylib';
      args.addAll(['-undefined', 'dynamic_lookup']);
    }

    config.define?.forEach((key, value) {
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
      args.addAll(config.flags ?? []);

    config.sources?.forEach(args.add);

    config.link?.forEach((s) => args.add('-l$s'));

    args.addAll(['-o', libname]);

    var exec = '$cc ${args.join(' ')}'.trim();
    print(exec);

    var process = await Process.start(cc, args, workingDirectory: wDir);
    var code = await process.exitCode;

    if (code != 0) {
      var out = await process.stdout.transform(utf8.decoder).join();
      var err = await process.stderr.transform(utf8.decoder).join();
      if (out.isNotEmpty) log.info(out);
      if (err.isNotEmpty) log.severe(err);
      log.severe('$exec terminated with exit code $code.');
      throw '$exec terminated with exit code $code.';
    } else {
      await process.stderr.toList();
      await process.stdout.toList();
    }
  }

  linkWindows(AssetId asset, String wDir, BuildNativeConfig config,
      BuildStep buildStep, String defaultCC) async {
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
      var cl = await Process.run(Platform.environment['CC'] ?? defaultCC, [
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

  linkLinux(AssetId asset, String wDir) async {
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
