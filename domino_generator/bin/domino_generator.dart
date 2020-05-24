import 'package:args/command_runner.dart';

import 'package:domino_generator/src/commands/compile.dart';

Future<void> main(List<String> args) async {
  final runner = CommandRunner(
      'domino_generator', 'Code generator for the domino package.')
    ..addCommand(CompileCommand());
  await runner.run(args);
}
