import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:build/build.dart';
import 'package:build_native/src/common.dart';
import 'package:build_native/src/platform_type.dart';
import 'package:io/ansi.dart';
import 'package:yaml/yaml.dart' as yaml;

class DoctorCommand extends Command {
  @override
  String get name => 'doctor';

  @override
  String get description =>
      'Queries the status of tools necessary for building extensions.';

  Future<String> query(String executable, List<String> arguments) async {
    try {
      var output = await execProcess(executable, arguments);
      return await output
          .transform(utf8.decoder)
          .transform(LineSplitter())
          .first
          .then((s) => s.trim())
          .then((s) => s.isNotEmpty ? s : throw s);
    } catch (_) {
      return null;
    }
  }

  void printInfo(
      AnsiCode color, String symbol, String executable, String message) {
    var s = '`$executable` - $message';
    if (ansiOutputEnabled) s = '[$symbol] $s';
    print(color.wrap(s));
  }

  void printNotFound(String executable) =>
      printInfo(red, '\u2717', executable, 'Not installed');

  void printVersion(String executable, String version) =>
      printInfo(green, '\u2713', executable, version);

  @override
  FutureOr run() async {
    var platformType = PlatformType.thisSystem(BuilderOptions.empty);
    print(cyan.wrap('Detected platform type - `${platformType.name}`'));
    print(cyan.wrap('Checking build environment...\n'));

    print(yellow
        .wrap('System `PATH` variable: ${Platform.environment['PATH']}\n'));

    // Check for Pub
    try {
      var pubVersion = await query('pub', ['version']);
      printVersion('pub', pubVersion);
    } catch (_) {
      printNotFound('pub');
      exitCode = 1;
    }

    // Check for pbr
    try {
      var pubspecLockFile = new File('pubspec.lock');
      var publock = yaml.loadYaml(await pubspecLockFile.readAsString(),
          sourceUrl: pubspecLockFile.uri);
      var pbrVersion = publock['packages']['build_runner']['version'] as String;
      if (pbrVersion?.isNotEmpty != true) throw pbrVersion;
      printVersion('build_runner', 'version $pbrVersion');
    } catch (_) {
      printNotFound('build_runner');
    }

    // Check for Git
    try {
      var gitVersion = await query('git', ['version']);
      printVersion('git', gitVersion);
    } catch (_) {
      printNotFound('git');
    }

    if (platformType == PlatformType.windows) {
      // TODO: Complete Windows support. Check for compilers, etc.
      //throw new UnimplementedError('The `doctor` command does not yet completely support Windows.');
    } else {
      // Check for `gcc`/clang

      if (platformType == PlatformType.macOS) {
        try {
          var clangVersion = await query('clang', ['--version']);
          printVersion('clang', clangVersion);
        } catch (_) {
          printNotFound('clang');
        }
      } else {
        try {
          var gccVersion = await query('gcc', ['--version']);
          printVersion('gcc', gccVersion);
        } catch (_) {
          printNotFound('gcc');
        }

        try {
          var gppVersion = await query('g++', ['--version']);
          printVersion('g++', gppVersion);
        } catch (_) {
          printNotFound('g++');
        }
      }

      // Check for Make
      try {
        var makeVersion = await query('make', ['--version']);
        printVersion('make', makeVersion);
      } catch (_) {
        printNotFound('make');
      }

      // Check for sh
      try {
        var shVersion = await query('sh', ['--version']);
        printVersion('sh', shVersion);
      } catch (_) {
        printNotFound('sh');
      }
    }
  }
}
