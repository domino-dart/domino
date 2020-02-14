import 'dart:io';

import 'package:domino_generator/src/component_generator.dart';

void main() {
  final gen = ComponentGenerator();
  final sourceContent = File('example/ex1/ex1.html').readAsStringSync();
  final x = gen.generateSource(sourceContent);
  File('example/ex1/ex1.g.dart').writeAsStringSync(x);
}
