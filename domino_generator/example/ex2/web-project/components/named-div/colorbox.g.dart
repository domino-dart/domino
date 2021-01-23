import 'package:domino/src/experimental/idom.dart' as _i1;

void renderRedBox(_i1.DomContext $d) {
  $d.open('div');
  $d.attr('style', 'background-color: red; width: 10px; height: 10px');
  $d.text('\n        X\n    ');
  $d.close();
}

void renderBlueBox(_i1.DomContext $d) {
  $d.open('div');
  $d.attr('style', 'background-color: blue; width: 10px; height: 10px');
  $d.text('\n        O\n        ');
  $d.open('b');
  $d.text('\n            O\n        ');
  $d.close();
  $d.close();
}
