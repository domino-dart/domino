import 'package:domino/src/experimental/idom.dart' as _i0
    show DomContext, SlotFn;
import 'package:intl/intl.dart' as _i1 show Intl;

void renderRedBox(_i0.DomContext $d) {
  $d.clazz('ds_1b0a43d1a5df11d59cc6');

  $d.open('div');
  {
    String text_X_4b68ab38() =>
        _i1.Intl.message('X', name: 'text_X_4b68ab38', args: [], desc: '');
    $d.text(text_X_4b68ab38());
  }
  $d.close();
}

void renderBlueBox(
  _i0.DomContext $d, {
  _i0.SlotFn slot,
}) {
  $d.clazz('ds_fea58795f3a2aa58e9a7');

  $d.open('div');
  {
    String text_BB_fc686c31() =>
        _i1.Intl.message('BB', name: 'text_BB_fc686c31', args: [], desc: '');
    $d.text(text_BB_fc686c31());
  }
  if (slot != null) {
    slot($d);
  }
  {
    String text_LO_ec0bade9() =>
        _i1.Intl.message('LO', name: 'text_LO_ec0bade9', args: [], desc: '');
    $d.text(text_LO_ec0bade9());
  }
  $d.close();
}
