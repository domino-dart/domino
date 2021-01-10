import 'dart:io';

import 'package:args/command_runner.dart';

import '../../domino_generator.dart';

class CompileCommand extends Command {
  @override
  String get name => 'compile';

  @override
  String get description =>
      'Compiles HTML templates into Incremental DOM render functions.';

  CompileCommand() {
    argParser
      ..addOption('path',
          help: 'The file or the root directory of the templates.')
      ..addOption('library',
          help: 'The .dart file inside the root directory that will export '
              'all of the generated template files.')
      ..addOption('sass',
          help: 'The .scss file inside the root directory that will import '
              'all of the generated .scss files.');
  }

  @override
  Future<void> run() async {
    final path = argResults['path'] as String;
    ArgumentError.checkNotNull(path, 'path');

    if (await FileSystemEntity.isFile(path)) {
      // generate single template
      await compileFile(path);
    } else {
      // generate all templates in a directory, recursively
      final libraryName = argResults['library'] as String;
      final sassName = argResults['sass'] as String;

      await compileDirectory(path,
          libraryName: libraryName, sassName: sassName);
    }
  }
}
