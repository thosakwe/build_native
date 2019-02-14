import 'package:args/command_runner.dart';
import 'doctor.dart';
import 'scaffold.dart';

final CommandRunner commandRunner = new CommandRunner('build_native',
    'Compile native extensions with package:build, using the system compilers.')
  ..addCommand(new DoctorCommand())
  ..addCommand(new ScaffoldCommand());
