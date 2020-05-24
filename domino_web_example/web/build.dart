import 'package:domino_generator/domino_generator.dart' as cg;

Future<void> main() async {
  await cg.compileDirectory('web/templates', debugParse: true);
}
