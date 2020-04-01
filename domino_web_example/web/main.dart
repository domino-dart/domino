import 'dart:html';
import 'templates/mainElem.g.dart';
import 'package:domino/src/experimental/idom_browser.dart' as ib;

void main() {
  querySelector('#output').text = 'Not changed';
  final ctx = ib.BrowserDomContext(querySelector('#output'));
  ctx.text('Text context');
  renderMain(ctx, clickName: 'Click me!');
}
