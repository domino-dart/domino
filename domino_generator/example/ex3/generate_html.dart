import 'dart:io';

import 'package:domino/src/experimental/idom_server.dart';

import 'web-project/ex3.g.dart';

void main() {
  final sdc = ServerDomContext();
  ex3(sdc);
  sdc.writeHTML(
      out: File('example/ex3/hope-it-works.html').openWrite(),
      indent: ' ',
      indentAttr: true,
      lineEnd: '\n');
}