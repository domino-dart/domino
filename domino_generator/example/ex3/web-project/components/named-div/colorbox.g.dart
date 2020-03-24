import 'package:domino/src/experimental/idom.dart' as _i0
    show DomContext, SlotFn;

void renderRedBox(_i0.DomContext $d) {
  $d.open('div');
  $d.attr('style', 'background-color: red; width: 100px; height: 100px');
  $d.text('\n        X\n    ');
  $d.close();
}

void renderBlueBox(
  _i0.DomContext $d, {
  _i0.SlotFn slot,
}) {
  $d.open('div');
  $d.attr('style', 'background-color: blue; width: 100px; height: 100px');
  $d.text('\n        BB\n        ');
  slot($d);
  $d.text('\n        LO\n    ');
  $d.close();
}
