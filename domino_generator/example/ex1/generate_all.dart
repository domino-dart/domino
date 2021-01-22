import 'package:domino_generator/domino_generator.dart';

Future<void> main() async {
  await compileFile('example/ex1/ex1.html', debugParse: true);
}
