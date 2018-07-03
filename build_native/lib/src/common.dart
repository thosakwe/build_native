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

Future<Stream<List<int>>> execProcess(String executable, List<String> arguments,
    [String workingDirectory, bool withTimeout = true]) async {
  var exec = '$executable ';
  exec += arguments.join(' ');
  exec = exec.trim();
  if (workingDirectory != null) exec += ' (in $workingDirectory)';
  log.config(exec);
  var process = await Process.start(executable, arguments,
      workingDirectory: workingDirectory);
  var code = await (withTimeout
      ? avoidHangingProcess(process, exec)
      : process.exitCode);

  if (code != 0) {
    var out = await process.stdout.transform(const Utf8Decoder(allowMalformed: true)).join();
    var err = await process.stderr.transform(const Utf8Decoder(allowMalformed: true)).join();
    if (out.isNotEmpty) log.info(out);
    if (err.isNotEmpty) log.severe(err);
    log.severe('$exec terminated with exit code $code.');
    throw '$exec terminated with exit code $code.';
  } else {
    await process.stderr.toList();
    return process.stdout;
  }
}

Future expectExitCode0(String executable, List<String> arguments,
    [String workingDirectory, bool withTimeout = true]) {
  return expectExitCode(
      executable, arguments, [0], workingDirectory, withTimeout);
}

void listenToProcess(Process process, [bool withStdout = false]) {
  if (withStdout) {
    process.stdout
        .transform(const Utf8Decoder(allowMalformed: true))
        .transform(LineSplitter())
        .listen(log.info);
  }

  process.stderr
      .transform(const Utf8Decoder(allowMalformed: true))
      .transform(LineSplitter())
      .listen(log.warning);
}

Future<int> avoidHangingProcess(Process process, String exec) {
  var timeout = const Duration(minutes: 5);
  return process.exitCode.timeout(timeout, onTimeout: () {
    process.kill();
    throw 'The process $exec took too long to complete.';
  });
}

Future expectExitCode(
    String executable, List<String> arguments, List<int> allowedExitCodes,
    [String workingDirectory, bool withTimeout = true]) async {
  var exec = '$executable ';
  exec += arguments.join(' ');
  exec = exec.trim();
  log.config(exec);
  if (workingDirectory != null) exec += ' (in $workingDirectory)';
  var process = await Process.start(executable, arguments,
      workingDirectory: workingDirectory);
  listenToProcess(process, true);
  var code = await (withTimeout
      ? avoidHangingProcess(process, exec)
      : process.exitCode);

  if (!allowedExitCodes.contains(code)) {
    throw '$exec terminated with exit code $code.';
  } else {
    return code;
  }
}

Future handleProcess(Process process, String exec, BuildStep buildStep,
    ScratchSpace scratchSpace, AssetId outAsset) async {
  log.config(exec);
  listenToProcess(process);
  var code = await process.exitCode;

  if (code != 0) {
    var out = await process.stdout.transform(const Utf8Decoder(allowMalformed: true)).join();
    if (out.isNotEmpty) log.info(out);
    throw '$exec terminated with exit code $code.';
  } else {
    await process.stderr.toList();
    scratchSpace.copyOutput(outAsset, buildStep);
  }
}
