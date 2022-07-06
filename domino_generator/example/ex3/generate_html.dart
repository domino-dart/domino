import 'dart:io';

// ignore: import_of_legacy_library_into_null_safe
import 'package:domino/src/experimental/idom_server.dart';

import 'web-project/ex3.g.dart';

Future<void> main() async {
  final sdc = ServerDomContext();
  renderEx3(sdc);
  final ex3File = File('example/ex3/hope-it-works.html').openWrite();
  sdc.writeHTML(out: ex3File, indent: ' ', indentAttr: true, lineEnd: '\n');
  await ex3File.close();
}
