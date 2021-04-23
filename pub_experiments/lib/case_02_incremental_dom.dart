import 'package:domino/src/experimental/idom_server.dart';

import 'case_02_incremental_dom.g.dart';
import 'data.dart';

void main() {
  final context = ServerDomContext();
  renderTags(context, data: data);
  final out = StringBuffer();
  context.writeHTML(out: out, indent: '  ');
  print(out);
}
