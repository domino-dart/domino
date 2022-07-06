import 'dart:io';

// ignore: import_of_legacy_library_into_null_safe
import 'package:domino/src/experimental/idom_server.dart';
import 'ex1.g.dart';
import 'ex1_model.dart';

Future<void> main() async {
  final ctx = ServerDomContext();

  final ex1 = Example()
    ..text = 'Text 1'
    ..name = 'Example 1'
    ..number = 1
    ..items = [
      Item()
        ..visible = true
        ..label = 'Visible item',
      Item()
        ..visible = false
        ..label = 'Unvisible item',
      Item()
        ..visible = true
        ..label = 'Visible item 2',
    ];

  renderEx1(ctx, extra: true, obj: ex1);

  final ex1Indent = File('example/ex1/ex1_indent.html').openWrite();
  ctx.writeHTML(out: ex1Indent, indent: '    ');
  await ex1Indent.close();

  final ex1IndentAttr = File('example/ex1/ex1_indent.html').openWrite();
  ctx.writeHTML(out: ex1IndentAttr, indent: '    ', indentAttr: true);
  await ex1IndentAttr.close();

  final ex1NoIndent = File('example/ex1/ex1_noindent.html').openWrite();
  ctx.writeHTML(out: ex1NoIndent, indent: null);
  await ex1NoIndent.close();
}
