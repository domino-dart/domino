import 'package:domino/src/experimental/idom.dart' as _i0
    show DomContext, SlotFn;

void renderRedBox(_i0.DomContext $d) {
  $d.clazz('ds_1b0a43d1a5df11d59cc6');

  $d.open('div');
  {
    String t4b68ab38$X() =>
        (_$strings[r't4b68ab38$X'].containsKey($d.globals.locale)
                ? _$strings[r't4b68ab38$X'][$d.globals.locale]
                : _$strings[r't4b68ab38$X'][''])
            .toString();
    $d.text(t4b68ab38$X());
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
    String tfc686c31$Bb() =>
        (_$strings[r'tfc686c31$Bb'].containsKey($d.globals.locale)
                ? _$strings[r'tfc686c31$Bb'][$d.globals.locale]
                : _$strings[r'tfc686c31$Bb'][''])
            .toString();
    $d.text(tfc686c31$Bb());
  }
  if (slot != null) {
    slot($d);
  }
  {
    String tec0bade9$Lo() =>
        (_$strings[r'tec0bade9$Lo'].containsKey($d.globals.locale)
                ? _$strings[r'tec0bade9$Lo'][$d.globals.locale]
                : _$strings[r'tec0bade9$Lo'][''])
            .toString();
    $d.text(tec0bade9$Lo());
  }
  $d.close();
}

const _$strings = {
  r't4b68ab38$X': {
    '_params': r'{}',
    '': r'X',
  },
  r'tfc686c31$Bb': {
    '_params': r'{}',
    '': r'BB',
  },
  r'tec0bade9$Lo': {
    '_params': r'{}',
    '': r'LO',
  },
};
