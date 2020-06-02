import 'package:domino/src/experimental/idom.dart' as _i0 show DomContext;
import 'package:intl/intl.dart' as _i1 show Intl;
import './components/named-div/button.g.dart' as _i2 show renderButton;
import './components/named-div/library.dart' as _i3
    show renderBlueBox, renderRedBox;

void renderEx3(_i0.DomContext $d) {
  $d.open('button');
  {
    String text_The_best_button_c49a9a67() =>
        _i1.Intl.message('The best button',
            name: 'text_The_best_button_c49a9a67', args: [], desc: '');
    $d.text(text_The_best_button_c49a9a67());
  }
  $d.close();
  _i2.renderButton($d);
  _i3.renderRedBox($d);
  _i3.renderBlueBox($d, slot: (_i0.DomContext $d) {
    {
      String text_Here_is_an_20be9e0a() =>
          _i1.Intl.message('Here is an input field:',
              name: 'text_Here_is_an_20be9e0a', args: [], desc: '');
      $d.text(text_Here_is_an_20be9e0a());
    }
    $d.open('input');
    $d.close();
    {
      String text_And_a_button_846efa2d() =>
          _i1.Intl.message('And a button component from somewhere',
              name: 'text_And_a_button_846efa2d', args: [], desc: '');
      $d.text(text_And_a_button_846efa2d());
    }
    $d.open('d.button');
    $d.close();
  });
}
