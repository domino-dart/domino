import 'dart:async';
import 'dart:html';

import 'package:domino/domino.dart' as old;
import 'package:domino/html_view.dart' as old_html;
import 'package:domino/src/experimental/idom_browser.dart' as ib;
import 'package:domino/src/experimental/ddom.dart' as ddom;
import 'package:domino/src/experimental/ddom_browser.dart' as db;

void main() {
  // 567k-627k
  // 486k-498k
  // 396k
  document.getElementById('b1').onClick.listen((_) {
    _benchmark(() => _oldInit(), () => _old());
  });
  // 237k-339k
  // 469k-483k
  document.getElementById('b2').onClick.listen((_) async {
    await _benchmark(() => _idomInit(), () => _idom());
  });
  // 225-236k
  // 202k
  // 494k-536k / 419k
  document.getElementById('b3').onClick.listen((_) async {
    await _benchmark(() => _ddomInit(), () => _ddom());
  });
}

Future<void> _benchmark(
    Future<void> Function() init, void Function() fn) async {
  await init();
  final sw = Stopwatch()..start();
  var count = 0;
  for (;; count++) {
    if (count % 100000 == 0) {
      print('$count in ${sw.elapsed}');
    }
    await fn();
    if (sw.elapsed.inSeconds > 9) break;
  }
  print('total: $count in ${sw.elapsed}');
}

old.View _oldView;
Future<void> _oldInit() async {
  final output = document.getElementById('output');
  output.innerHtml = '';
  _oldView = old_html.registerHtmlView(output, OC());
}

class OC implements old.Component {
  @override
  dynamic build(old.BuildContext context) {
    return [
      old.Element('div', [
        old.attr('title', 'abc'),
        old.clazz('c1'),
        old.style('background', 'red'),
        old.Element('span', ['text1']),
        old.Element('span', [() => 'text2']),
      ])
    ];
  }
}

void _old() {
  _oldView.update();
}

Element _idomRoot;
Future<void> _idomInit() async {
  final output = document.getElementById('output');
  output.innerHtml = '';
  output.append(_idomRoot = DivElement());
}

void _idom() {
  ib.patch(_idomRoot, (ctx) {
    ctx.open('div');
    ctx.attr('title', 'abc');
    ctx.clazz('c1');
    ctx.style('background', 'red');
    ctx.open('span');
    ctx.text('text1');
    ctx.close();
    ctx.open('span');
    final t2 = () =>'text2';
    ctx.text(t2());
    ctx.close();
    ctx.close();
  });
}

ddom.DView _ddomView;
Future<void> _ddomInit() async {
  final output = document.getElementById('output');
  output.innerHtml = '';
  _ddomView = db.bindHtmlView(
      output,
      () => [
            ddom.DElem('div',
                attrs: ddom.DStringMap(values: {'title': 'abc'}),
                classes: ddom.DStringList(values: ['c1']),
                styles: ddom.DStringMap(values: {'background': 'red'}),
                children: [
                  ddom.DElem('span', children: [ddom.DText('text1')]),
                  ddom.DElem('span', children: [ddom.DText.fn(() => 'text2')])
                ]),
          ]);
}

void _ddom() {
  _ddomView.update();
}
