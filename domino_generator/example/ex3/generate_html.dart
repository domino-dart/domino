import 'dart:io';

import 'package:domino/src/experimental/idom_server.dart';

import 'web-project/ex3.g.dart';

void main() async {
  final sdc = ServerDomContext();
  renderEx3(sdc);
  final ex3File = File('example/ex3/hope-it-works.html').openWrite();
  sdc.writeHTML(
      out: ex3File,
      indent: ' ',
      indentAttr: true,
      lineEnd: '\n');
  await ex3File.close();
}