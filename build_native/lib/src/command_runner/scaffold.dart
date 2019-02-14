import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:io/ansi.dart';
import 'package:io/io.dart';
import 'package:path/path.dart' as p;
import 'package:recase/recase.dart';
import 'package:yaml/yaml.dart' as yaml;

class ScaffoldCommand extends Command {
  @override
  String get name => 'scaffold';

  @override
  String get description =>
      'Generates boilerplate for a basic native extension.';

  ScaffoldCommand() {
    argParser
      ..addOption('directory',
          abbr: 'd',
          defaultsTo: p.join('lib', 'src'),
          help: 'The directory to create the file in.');
  }

  run() async {
    if (argResults.rest.isEmpty) {
      throw new UsageException(
          'Missing a name for the created native extension, ex. "say_hello".',
          usage);
    } else {
      var pubspecFile = new File('pubspec.yaml');
      if (!await pubspecFile.exists()) {
        stderr
            .writeln('No `pubspec.yaml` file exists in the current directory.');
        exitCode = ExitCode.osFile.code;
        return;
      }

      var pubspecYaml = await yaml.loadYamlNode(
          await pubspecFile.readAsString(),
          sourceUrl: pubspecFile.uri) as yaml.YamlMap;
      var package = pubspecYaml['name']?.toString();

      if (package?.isNotEmpty != true) {
        stderr.writeln(
            'There is no `name` defined in `pubspec.yaml`; please add one before continuing.');
        exitCode = ExitCode.config.code;
        return;
      }

      var name = new ReCase(argResults.rest[0]);
      var dir = argResults['directory'].toString();
      var ccPath = p.setExtension(p.join(dir, name.snakeCase), '.cc');
      var dartPath = p.setExtension(ccPath, '.dart');
      var libname = 'lib' + p.basename(ccPath);
      var yamlPath = p.setExtension(
          p.join(p.dirname(ccPath), libname), '.build_native.yaml');
      await new Directory(dir).create(recursive: true);
      await new File(ccPath).writeAsString(cppFile(name));
      await new File(dartPath).writeAsString(dartFile(name));
      await new File(yamlPath).writeAsString(yamlFile(package, ccPath));

      print(green.wrap('Created the extension `${name.snakeCase}`:'));
      print(green.wrap('  * $ccPath'));
      print(green.wrap('  * $dartPath'));
      print(green.wrap('  * $yamlPath'));
    }
  }

  String yamlFile(String package, String ccPath) {
    return '''
sources:
  - $package|${p.relative(ccPath)}
    '''
        .trim();
  }

  String dartFile(ReCase name) {
    return '''
import 'dart-ext:${name.snakeCase}';

void sayHello() native "SayHello";
    '''
        .trim();
  }

  String cppFile(ReCase name) {
    return '''
#include <cstdlib>
#include <iostream>
#include <string.h>
#include <dart_api.h>

// Forward declaration of ResolveName function.
Dart_NativeFunction ResolveName(Dart_Handle name, int argc, bool* auto_setup_scope);

// The name of the initialization function is the extension name followed
// by _Init.
DART_EXPORT Dart_Handle ${name.snakeCase}_Init(Dart_Handle parent_library) {
  if (Dart_IsError(parent_library)) return parent_library;

  Dart_Handle result_code =
      Dart_SetNativeResolver(parent_library, ResolveName, NULL);
  if (Dart_IsError(result_code)) return result_code;

  return Dart_Null();
}

Dart_Handle HandleError(Dart_Handle handle) {
 if (Dart_IsError(handle)) Dart_PropagateError(handle);
 return handle;
}

// Native functions get their arguments in a Dart_NativeArguments structure
// and return their results with Dart_SetReturnValue.
void SayHello(Dart_NativeArguments arguments) {
  std::cout << "Hello, native world!" << std::endl;
  Dart_SetReturnValue(arguments, Dart_Null());
}

Dart_NativeFunction ResolveName(Dart_Handle name, int argc, bool* auto_setup_scope) {
  // If we fail, we return NULL, and Dart throws an exception.
  if (!Dart_IsString(name)) return NULL;
  Dart_NativeFunction result = NULL;
  const char* cname;
  HandleError(Dart_StringToCString(name, &cname));

  if (strcmp("SayHello", cname) == 0) result = SayHello;
  return result;
}
    '''
        .trim();
  }
}
