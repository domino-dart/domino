import 'package:domino/src/experimental/idom.dart' as _i0 show DomContext;
import 'components/named-div/button.g.dart' as _i1 show renderButton;
import 'components/named-div/colorbox.g.dart' as _i2 show renderRedBox;

void renderEx2(_i0.DomContext $d) {
  $d.open('button');
  {
    String text_The_best_button_c49a9a67() =>
        ($strings[r'text_The_best_button_c49a9a67']
                    .containsKey($d.globals['locale'])
                ? $strings[r'text_The_best_button_c49a9a67']
                    [$d.globals['locale']]
                : $strings[r'text_The_best_button_c49a9a67'][''])
            .toString();
    $d.text(text_The_best_button_c49a9a67());
  }
  $d.close();
  _i1.renderButton($d);
  _i2.renderRedBox($d);
}

const $strings = {
  'text_The_best_button_c49a9a67': {
    '_params': r'{}',
    '': r'The best button',
  },
};
