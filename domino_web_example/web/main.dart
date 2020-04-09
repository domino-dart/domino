import 'dart:html';
import 'templates/mainElem.g.dart';
import 'package:domino/src/experimental/idom_browser.dart' as ib;

void main() {
  querySelector('#output').text = 'Not changed';
  final ctx = ib.BrowserDomContext(querySelector('#output'));
  ctx.text('Text context');
  ctx.open('div');
  for(var i = 1; i <= 10; ++i) {
    ctx.text('value $i\n');
  }
  ctx.close();
  renderMain(ctx, clickName: 'Click me!');
}

void betterAlert(String text){
  window.alert('BETTER $text');
}
