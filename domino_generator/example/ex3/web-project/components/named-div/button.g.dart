import 'package:domino/src/experimental/idom.dart' as _i0 show DomContext;

void renderButton(_i0.DomContext $d) {
  {
    String text_Named_8605605a() =>
        (_$strings[r'text_Named_8605605a'].containsKey($d.globals['locale'])
                ? _$strings[r'text_Named_8605605a'][$d.globals['locale']]
                : _$strings[r'text_Named_8605605a'][''])
            .toString();
    $d.text(text_Named_8605605a());
  }
  $d.open('b');
  {
    String text_Button_707eab0c() =>
        (_$strings[r'text_Button_707eab0c'].containsKey($d.globals['locale'])
                ? _$strings[r'text_Button_707eab0c'][$d.globals['locale']]
                : _$strings[r'text_Button_707eab0c'][''])
            .toString();
    $d.text(text_Button_707eab0c());
  }
  $d.close();
}

const _$strings = {
  'text_Named_8605605a': {
    '_params': r'{}',
    '': r'Named',
  },
  'text_Button_707eab0c': {
    '_params': r'{}',
    '': r'Button',
  },
};
