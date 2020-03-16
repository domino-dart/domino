import 'dart:io';

import 'package:domino/src/experimental/idom_server.dart';
import 'ex1.g.dart';
import 'ex1_model.dart';

void main() {
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

  Ex1(ctx, extra: true, obj: ex1);

  ctx.writeHTML(out: File('example/ex1/ex1_indent.html').openWrite(),
      indent: '    ');
  ctx.writeHTML(out: File('example/ex1/ex1_indentattr.html').openWrite(),
      indent: '    ', indentAttr: true);
  ctx.writeHTML(out: File('example/ex1/ex1_noindent.html').openWrite(),
      indent: null);
}
