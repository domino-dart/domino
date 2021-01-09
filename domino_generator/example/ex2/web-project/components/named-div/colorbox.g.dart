import 'package:domino/src/experimental/idom.dart' as _i0 show DomContext;

void renderRedBox(_i0.DomContext $d) {
  $d.open('div');
  $d.attr('style', 'background-color: red; width: 10px; height: 10px');
  {
    String text_X_4b68ab38() =>
        (_$strings[r'text_X_4b68ab38'].containsKey($d.globals.locale)
                ? _$strings[r'text_X_4b68ab38'][$d.globals.locale]
                : _$strings[r'text_X_4b68ab38'][''])
            .toString();
    $d.text(text_X_4b68ab38());
  }
  $d.close();
}

void renderBlueBox(_i0.DomContext $d) {
  $d.open('div');
  $d.attr('style', 'background-color: blue; width: 10px; height: 10px');
  {
    String text_O_c4694f2e() =>
        (_$strings[r'text_O_c4694f2e'].containsKey($d.globals.locale)
                ? _$strings[r'text_O_c4694f2e'][$d.globals.locale]
                : _$strings[r'text_O_c4694f2e'][''])
            .toString();
    $d.text(text_O_c4694f2e());
  }
  $d.open('b');
  {
    String text_O_c4694f2e() =>
        (_$strings[r'text_O_c4694f2e'].containsKey($d.globals.locale)
                ? _$strings[r'text_O_c4694f2e'][$d.globals.locale]
                : _$strings[r'text_O_c4694f2e'][''])
            .toString();
    $d.text(text_O_c4694f2e());
  }
  $d.close();
  $d.close();
}

const _$strings = {
  'text_X_4b68ab38': {
    '_params': r'{}',
    '': r'X',
  },
  'text_O_c4694f2e': {
    '_params': r'{}',
    '': r'O',
  },
};
