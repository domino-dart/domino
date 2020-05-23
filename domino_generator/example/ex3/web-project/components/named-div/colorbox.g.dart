import 'package:domino/src/experimental/idom.dart' as _i0
    show DomContext, SlotFn;

void renderRedBox(_i0.DomContext $d) {
  $d.clazz('ds_1b0a43d1a5df11d59cc6');

  $d.open('div');
  $d.text('\n        X\n    ');
  $d.close();
}

void renderBlueBox(
  _i0.DomContext $d, {
  _i0.SlotFn slot,
}) {
  $d.clazz('ds_fea58795f3a2aa58e9a7');

  $d.open('div');
  $d.text('\n        BB\n        ');
  if (slot != null) {
    slot($d);
  }
  $d.text('\n        LO\n    ');
  $d.close();
}
