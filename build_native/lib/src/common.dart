import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:build/build.dart';
import 'package:cli_util/cli_util.dart';
import 'package:path/path.dart' as p;
import 'package:scratch_space/scratch_space.dart';

String get includePath => p.absolute(p.join(getSdkPath(), 'include'));

String get dartLibPath => p.absolute(p.join(getSdkPath(), 'bin', 'dart.lib'));

final Resource<ScratchSpace> scratchSpaceResource =
    new Resource(() => new ScratchSpace(), dispose: (old) => old.delete());

Future<Stream<List>> execProcess(
    String executable, List<String> arguments) async {
  var exec = '$executable ';
  exec += arguments.join(' ');
  exec = exec.trim();
  var process = await Process.start(executable, arguments);
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
    return process.stdout;
  }
}

Future handleProcess(Process process, String exec, BuildStep buildStep,
    ScratchSpace scratchSpace, AssetId outAsset) async {
  print(exec);
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
    scratchSpace.copyOutput(outAsset, buildStep);
  }
}
