import 'package:domino_generator/domino_generator.dart' as idomg;

Future<void> main() async {
  await idomg.compileFile('lib/case_02_incremental_dom.html');
}
