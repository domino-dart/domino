import 'package:domino_generator/src/component_generator.dart' as cg;

void main() {
  cg.compileDirectory('web/templates', debugParse: true);
}
