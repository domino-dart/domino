import 'dart:html';
import 'templates/human.dart';
import 'templates/mainElem.g.dart';
import 'package:domino/src/experimental/idom.dart' as idom;
import 'package:domino/src/experimental/idom_browser.dart' as ib;

void main() {
  querySelector('#output').text = 'Not changed';
  final ctx = ib.BrowserDomContext(querySelector('#output'));
  ctx.text('Text context');
  ctx.open('div');
  for (var i = 1; i <= 10; ++i) {
    ctx.text('value $i\n');
  }
  ctx.close();
  final man = Human('Bob', 300, 'Earth');
  var clickFun;
  clickFun = (idom.DomEvent e) {
    window.alert('Hello from here with $man');
    man.name = 'Password';
    man.age = 600;
    man.location = 'Moon';
    final ctx = ib.BrowserDomContext(querySelector('#output'));
    renderMain(ctx, human: man, clickName: 'Click', clickFun: clickFun);
  };
  renderMain(ctx, human: man, clickName: 'Click!', clickFun: clickFun);

  querySelector('#clickButton').on['onClick'].listen((e) {
    window.alert('Hello from there');
  });
  //*/
}
