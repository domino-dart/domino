import 'package:domino/src/experimental/idom.dart' as _i0
    show DomContext, SlotFn;
import 'package:intl/intl.dart' as _i1 show Intl;

void renderRedBox(_i0.DomContext $d) {
  $d.clazz('ds_1b0a43d1a5df11d59cc6');

  $d.open('div');
  String text_70031() => _i1.Intl.message('\n        X\n    ',
      name: 'text_70031', args: [], desc: '');
  $d.text(text_70031());
  $d.close();
}

void renderBlueBox(
  _i0.DomContext $d, {
  _i0.SlotFn slot,
}) {
  $d.clazz('ds_fea58795f3a2aa58e9a7');

  $d.open('div');
  String text_61938() => _i1.Intl.message('\n        BB\n        ',
      name: 'text_61938', args: [], desc: '');
  $d.text(text_61938());
  if (slot != null) {
    slot($d);
  }
  String text_38245() => _i1.Intl.message('\n        LO\n    ',
      name: 'text_38245', args: [], desc: '');
  $d.text(text_38245());
  $d.close();
}
