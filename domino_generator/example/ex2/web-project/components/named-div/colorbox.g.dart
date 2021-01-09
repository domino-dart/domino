import 'package:domino/src/experimental/idom.dart' as _i0 show DomContext;

void renderRedBox(_i0.DomContext $d) {
  $d.open('div');
  $d.attr('style', 'background-color: red; width: 10px; height: 10px');
  $d.text('X');
  $d.close();
}

void renderBlueBox(_i0.DomContext $d) {
  $d.open('div');
  $d.attr('style', 'background-color: blue; width: 10px; height: 10px');
  $d.text('O');
  $d.open('b');
  $d.text('O');
  $d.close();
  $d.close();
}
