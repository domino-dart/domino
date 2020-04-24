import 'package:domino/src/experimental/idom.dart' as _i0
    show DomContext, SlotFn;

void renderRedBox(_i0.DomContext $d) {
  $d.open('d-style');
  $d.clazz('named-div_renderRedBox');

  $d.text(
      '\n        background-color: red;\n        width: 100px;\n        height: 100px;\n    ');
  $d.close();
  $d.open('div');
  $d.clazz('named-div_renderRedBox');

  $d.text('\n        X\n    ');
  $d.close();
}

void renderBlueBox(
  _i0.DomContext $d, {
  _i0.SlotFn slot,
}) {
  $d.open('d-style');
  $d.clazz('named-div_renderBlueBox');

  $d.text(
      '\n        background-color: blue;\n        width: 100px;\n        height: 100px;\n    ');
  $d.close();
  $d.open('div');
  $d.clazz('named-div_renderBlueBox');

  $d.text('\n        BB\n        ');
  slot($d);
  $d.text('\n        LO\n    ');
  $d.close();
}
