import 'package:domino/src/experimental/idom.dart' as _i0 show DomContext;
import './components/named-div/button.g.dart' as _i1 show renderButton;
import './components/named-div/library.dart' as _i2
    show renderBlueBox, renderRedBox;

void renderEx3(_i0.DomContext $d) {
  $d.open('button');
  {
    String text_The_best_button_c49a9a67() =>
        (_$strings[r'text_The_best_button_c49a9a67']
                    .containsKey($d.globals.locale)
                ? _$strings[r'text_The_best_button_c49a9a67'][$d.globals.locale]
                : _$strings[r'text_The_best_button_c49a9a67'][''])
            .toString();
    $d.text(text_The_best_button_c49a9a67());
  }
  $d.close();
  _i1.renderButton($d);
  _i2.renderRedBox($d);
  _i2.renderBlueBox($d, slot: (_i0.DomContext $d) {
    {
      String text_Here_is_an_20be9e0a() =>
          (_$strings[r'text_Here_is_an_20be9e0a'].containsKey($d.globals.locale)
                  ? _$strings[r'text_Here_is_an_20be9e0a'][$d.globals.locale]
                  : _$strings[r'text_Here_is_an_20be9e0a'][''])
              .toString();
      $d.text(text_Here_is_an_20be9e0a());
    }
    $d.open('input');
    $d.close();
    {
      String text_And_a_button_846efa2d() =>
          (_$strings[r'text_And_a_button_846efa2d']
                      .containsKey($d.globals.locale)
                  ? _$strings[r'text_And_a_button_846efa2d'][$d.globals.locale]
                  : _$strings[r'text_And_a_button_846efa2d'][''])
              .toString();
      $d.text(text_And_a_button_846efa2d());
    }
    $d.open('d.button');
    $d.close();
  });
}

const _$strings = {
  'text_The_best_button_c49a9a67': {
    '_params': r'{}',
    '': r'The best button',
  },
  'text_Here_is_an_20be9e0a': {
    '_params': r'{}',
    '': r'Here is an input field:',
  },
  'text_And_a_button_846efa2d': {
    '_params': r'{}',
    '': r'And a button component from somewhere',
  },
};
