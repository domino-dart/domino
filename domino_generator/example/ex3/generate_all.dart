import 'package:domino_generator/domino_generator.dart';

Future<void> main() async {
  await compileDirectory('example/ex3/web-project',
      debugParse: true, i18n: true);
}
