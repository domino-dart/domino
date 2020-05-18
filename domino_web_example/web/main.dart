import 'dart:async';
import 'dart:html';
import 'package:async_tracker/async_tracker.dart';

import 'templates/human.dart';
import 'templates/mainElem.g.dart';
import 'package:domino/src/experimental/idom.dart' as idom;
import 'package:domino/src/experimental/idom_browser.dart' as ib;

void main() {
  final tracker = AsyncTracker();
  final man = Human('Bob', 10, 'Earth');
  final output = querySelector('#output');
  output.text = 'Not changed';
  void renderAll() {
    final ctx = ib.BrowserDomContext(output);
    ctx.text('Text context');
    ctx.open('div');
    for (var i = 1; i <= man.age; ++i) {
      ctx.text('value $i\n');
    }
    ctx.close();
    var clickFun;
    clickFun = (idom.DomEvent e) {
      //window.alert('Hello from here with $man');
      man.name = 'password';
      man.age = 20;
      man.location = 'Moon';
    };
    renderMain(ctx, human: man, clickName: 'Click!', clickFun: clickFun);
    ctx.close();

    querySelector('#clickButton').on['onClick'].listen((e) {
      window.alert('Hello from there');
    });
  };

  var canUpdate = false;
  Timer.periodic(Duration(milliseconds: 50), (t) {canUpdate = true;});
  tracker.addListener(() {
    if(canUpdate) {
      canUpdate = false;
      tracker.run(renderAll);
    }
  });
  tracker.run(renderAll);
  //*/
}
