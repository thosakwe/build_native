import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:build/build.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart' as yaml;
import 'models/models.dart';
import 'common.dart';
import 'platform_type.dart';

Builder cmakeBuilder(BuilderOptions builderOptions) =>
    new CMakeBuilder(builderOptions);

class CMakeBuilder implements Builder {
  final BuilderOptions builderOptions;

  CMakeBuilder(this.builderOptions);

  @override
  Map<String, List<String>> get buildExtensions {
    return const {
      //'.c': const ['.o'],
      //'.cc': const ['.o'],
      //'.cpp': const ['.o'],
      '.build_native.yaml': const [
        '.so',
        '.dylib',
        '.dll',
      ]
    };
  }

  @override
  Future build(BuildStep buildStep) async {
    var asset = buildStep.inputId;
    var platform = PlatformType.thisSystem(builderOptions);
    var projectName = p
        .basenameWithoutExtension(asset.path)
        .replaceFirst(new RegExp('^lib'), '');
    /*var projectName = p
        .basenameWithoutExtension(
            PlatformType.stripPlatformExtension(asset.path))
        .replaceFirst(new RegExp('^lib'), '');*/
    var scratchSpace = await buildStep.fetchResource(scratchSpaceResource);

    // Read the configuration file.
    var config = BuildNativeConfigSerializer.fromMap(
        yaml.loadYaml(await buildStep.readAsString(asset)));

    // Try to find platform-specific config.
    var platformSpecificConfigId =
        asset.changeExtension('${platform.name}.build_native.yaml');

    if (await buildStep.canRead(platformSpecificConfigId)) {
      var loadedYaml =
          yaml.loadYaml(await buildStep.readAsString(platformSpecificConfigId));
      var specific = BuildNativeConfigSerializer.fromMap(loadedYaml);
      config = config.copyWith(
        define: new Map.from(config.define ?? {})
          ..addAll(specific.define ?? {}),
        flags: new List.from(config.flags ?? [])..addAll(specific.flags ?? []),
        link: new List.from(config.link ?? [])..addAll(specific.link ?? []),
        sources: new List.from(config.sources ?? [])
          ..addAll(specific.sources ?? []),
      );
    }

    var libAsset = new AssetId(
      asset.package,
      p.setExtension(
          p.basenameWithoutExtension(asset.path), platform.libraryExtension),
    );
    //var libAsset =  asset.changeExtension(platform.libraryExtension);
    var libFile = scratchSpace.fileFor(libAsset);
    var libDir = libFile.parent.absolute.path;
    var cmakeLists = new StringBuffer();
    cmakeLists.writeln('cmake_minimum_required(VERSION 3.0)');
    //cmakeLists.writeln('project($projectName)');
    //cmakeLists.writeln('set(CMAKE_BINARY_DIR $libDir)');
    cmakeLists.writeln('set(CMAKE_CXX_STANDARD 11)');
    cmakeLists.writeln('set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "$libDir")');
    cmakeLists.writeln('set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "$libDir")');
    cmakeLists.writeln('set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "$libDir")');
    cmakeLists.writeln('set(CMAKE_POSITION_INDEPENDENT_CODE ON)');
    //cmakeLists.writeln('set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY $libDir)');
    //cmakeLists.writeln('set(CMAKE_LIBRARY_OUTPUT_DIRECTORY $libDir)');

    if (platform == PlatformType.macOS) {
      cmakeLists.writeln(
          r'set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -undefined dynamic_lookup")');
    }

    // Add compiler definitions, flags
    cmakeLists.writeln('add_definitions(-DDART_SHARED_LIB=1)');

    config.define?.forEach((k, v) {
      if (v?.toString()?.isNotEmpty == true) {
        cmakeLists.writeln('add_definitions("-D$k=$v")');
      } else {
        cmakeLists.writeln('add_definitions("-D$k")');
      }
    });

    if (config.flags?.isNotEmpty == true) {
      cmakeLists.writeln(
          'set(CMAKE_CXX_FLAGS "\${CMAKE_CXX_FLAGS} ${config.flags.join(
              ' ')}")');
      for (var flag in config.flags)
        cmakeLists.writeln('add_definitions("$flag")');
    }

    // Add include directories
    cmakeLists.writeln('include_directories("$includePath")');

    // Add sources
    cmakeLists.writeln('add_library($projectName SHARED');

    for (var source in config.sources ?? []) {
      var assetId = new AssetId.parse(source);
      await scratchSpace.ensureAssets([assetId], buildStep);
      cmakeLists
          .writeln('  "' + scratchSpace.fileFor(assetId).absolute.path + '"');
    }

    cmakeLists.writeln(')');

    // Add link directories, sources, etc.
    if (platform == PlatformType.windows) {
      cmakeLists.writeln('link_directories("$dartLibPath")');
    }

    for (var link in config.link ?? []) {
      var assetId = AssetId.parse(link);
      await scratchSpace.ensureAssets([assetId], buildStep);
      cmakeLists.write('target_link_libraries($projectName ');
      cmakeLists
          .writeln('  "' + scratchSpace.fileFor(assetId).absolute.path + '"');
      cmakeLists.writeln(')');
    }

    // Tell CMake where to put the library file...
    //cmakeLists.writeln(
    //    'install(TARGETS $projectName DESTINATION \${CMAKE_CURRENT_LIST_DIR})');

    log.info(cmakeLists);

    // Generate the text file.
    //var cmakeAsset = asset.changeExtension('.cmake');
    //var cmakeFile = scratchSpace.fileFor(cmakeAsset);
    //await cmakeFile.create(recursive: true);
    //await cmakeFile.writeAsString(cmakeLists.toString());
    //await scratchSpace.copyOutput(cmakeAsset, buildStep);

    // Include the generated file.

    //await buildStep.writeAsString(txtAsset, cmakeLists.toString());
    //await scratchSpace.ensureAssets([txtAsset], buildStep);

    // Next, run CMake...
    //var wDir = cmakeFile.parent.absolute;
    //var wPath = wDir.path;

    var tmp = Directory.systemTemp.createTempSync();
    var wPath = tmp.resolveSymbolicLinksSync();
    var cmakeListsTxtFile = new File.fromUri(tmp.uri.resolve('CMakeLists.txt'));
    bool exists = await cmakeListsTxtFile.exists();
    await cmakeListsTxtFile.create(recursive: true);
    await cmakeListsTxtFile.writeAsString(cmakeLists.toString());
    //await cmakeFile.create(recursive: true);
    //await cmakeFile.writeAsString(cmakeLists.toString());

    var sink = cmakeListsTxtFile.openWrite(mode: FileMode.writeOnlyAppend);
    if (!exists) sink.writeln('cmake_minimum_required(VERSION 3.0)');
    //sink.writeln('include ("${cmakeFile.absolute.path}")');
    await sink.close();

    Future doProcess(String cmd, List<String> args) async {
      var exec = '$cmd ${args.join(' ')}'.trim();
      log.warning('Now running `$exec` in $wPath...');

      var process = await Process.start(cmd, args, workingDirectory: wPath);
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
      }
    }

    await doProcess('cmake', ['.']);
    await doProcess('cmake', ['--build', '.', '--target', projectName]);

    //var genLibFile = new File.fromUri(libFile.parent.uri
    //   .resolve('lib${projectName}${platform.libraryExtension}'));
    //await genLibFile.copy(libFile.absolute.path);

    //await for (var e in libFile.parent.list(recursive: true)) {
    //  log.info('* ${e.absolute.path}\n');
    //}

    scratchSpace.copyOutput(libAsset, buildStep);
    await tmp.delete(recursive: true);
    //scratchSpace.copyOutput(outAsset, buildStep);
  }
}
