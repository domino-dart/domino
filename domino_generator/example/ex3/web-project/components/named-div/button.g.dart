import 'package:domino/src/experimental/idom.dart' as _i0 show DomContext;

void renderButton(_i0.DomContext $d) {
  {
    String t8605605a$Named() =>
        (_$strings[r't8605605a$Named'].containsKey($d.globals.locale)
                ? _$strings[r't8605605a$Named'][$d.globals.locale]
                : _$strings[r't8605605a$Named'][''])
            .toString();
    $d.text(t8605605a$Named());
  }
  $d.open('b');
  {
    String t707eab0c$Button() =>
        (_$strings[r't707eab0c$Button'].containsKey($d.globals.locale)
                ? _$strings[r't707eab0c$Button'][$d.globals.locale]
                : _$strings[r't707eab0c$Button'][''])
            .toString();
    $d.text(t707eab0c$Button());
  }
  $d.close();
}

const _$strings = {
  r't8605605a$Named': {
    '_params': r'{}',
    '': r'Named',
  },
  r't707eab0c$Button': {
    '_params': r'{}',
    '': r'Button',
  },
};
