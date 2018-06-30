import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:build_native/src/command_runner/command_runner.dart';
import 'package:io/ansi.dart';
import 'package:io/io.dart';

main(List<String> args) async {
  try {
    await commandRunner.run(args);
  } on UsageException catch (e) {
    stderr..writeln(yellow.wrap(e.message))..writeln()..writeln(e.usage);
    exitCode = ExitCode.usage.code;
  }
}
