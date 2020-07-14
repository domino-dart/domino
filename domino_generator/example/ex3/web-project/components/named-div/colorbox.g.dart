import 'package:domino/src/experimental/idom.dart' as _i0
    show DomContext, SlotFn;

void renderRedBox(_i0.DomContext $d) {
  $d.clazz('ds_1b0a43d1a5df11d59cc6');

  $d.open('div');
  {
    String text_X_4b68ab38() =>
        ($strings[r'text_X_4b68ab38'].containsKey($d.globals['locale'])
                ? $strings[r'text_X_4b68ab38'][$d.globals['locale']]
                : $strings[r'text_X_4b68ab38'][''])
            .toString();
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
        ($strings[r'text_BB_fc686c31'].containsKey($d.globals['locale'])
                ? $strings[r'text_BB_fc686c31'][$d.globals['locale']]
                : $strings[r'text_BB_fc686c31'][''])
            .toString();
    $d.text(text_BB_fc686c31());
  }
  if (slot != null) {
    slot($d);
  }
  {
    String text_LO_ec0bade9() =>
        ($strings[r'text_LO_ec0bade9'].containsKey($d.globals['locale'])
                ? $strings[r'text_LO_ec0bade9'][$d.globals['locale']]
                : $strings[r'text_LO_ec0bade9'][''])
            .toString();
    $d.text(text_LO_ec0bade9());
  }
  $d.close();
}

const $strings = {
  'text_X_4b68ab38': {
    '_params': r'{}',
    '': r'X',
  },
  'text_BB_fc686c31': {
    '_params': r'{}',
    '': r'BB',
  },
  'text_LO_ec0bade9': {
    '_params': r'{}',
    '': r'LO',
  },
};
