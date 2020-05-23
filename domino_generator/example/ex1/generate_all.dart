import 'dart:io';

import 'package:domino_generator/src/component_generator.dart';
import 'package:domino_generator/src/canonical.dart';

void main() {
  final gen = ComponentGenerator();
  final sourceContent = File('example/ex1/ex1.html').readAsStringSync();
  final y = parseToCanonical(sourceContent);
  File('example/ex1/ex1.g.html').writeAsStringSync('');
  for (final template in y.templates) {
    File('example/ex1/ex1.g.html').writeAsStringSync(
        template.toXmlString(pretty: true),
        mode: FileMode.append);
  }
  final x = gen.generateSource(sourceContent);
  File('example/ex1/ex1.g.dart').writeAsStringSync(x);
}
