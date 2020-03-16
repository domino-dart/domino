import 'dart:io';

//import 'package:domino_generator/src/component_generator.dart';
import 'package:domino_generator/src/canonical.dart';
import 'package:path/path.dart' as p;

void main() {
  for(final file in Directory('example/ex3/web-project').listSync(recursive: true)) {
    if(file is File && file.path.endsWith('.html') && !file.path.endsWith('.g.html')) {
      final source = file.readAsStringSync();
      final canSource = parseToCanonical(source);
      File(p.withoutExtension(file.path) + '.g.html').writeAsStringSync(canSource.templates.map((t) => t.outerHtml).join('\n\n'));
    }
  }
  return;
  //final gen = ComponentGenerator();
  //gen.compileDirectory('example/ex3/web-project');
}
