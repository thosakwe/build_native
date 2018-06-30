import 'package:args/command_runner.dart';

class ScaffoldCommand extends Command {
  @override
  String get name => 'scaffold';

  @override
  String get description =>
      'Generates boilerplate for a basic native extension.';

  ScaffoldCommand() {
    
  }
}
