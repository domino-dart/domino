import 'package:domino/src/experimental/idom.dart' as _i0 show DomContext;
import 'package:intl/intl.dart' as _i1 show Intl;
import './components/named-div/button.g.dart' as _i2 show renderButton;
import './components/named-div/library.dart' as _i3
    show renderBlueBox, renderRedBox;

void renderEx3(_i0.DomContext $d) {
  $d.open('button');
  String text_26932() => _i1.Intl.message('\n        The best button\n    ',
      name: 'text_26932', args: [], desc: '');
  $d.text(text_26932());
  $d.close();
  _i2.renderButton($d);
  _i3.renderRedBox($d);
  _i3.renderBlueBox($d, slot: (_i0.DomContext $d) {
    String text_33384() =>
        _i1.Intl.message('\n        Here is an input field:\n        ',
            name: 'text_33384', args: [], desc: '');
    $d.text(text_33384());
    $d.open('input');
    $d.close();
    String text_9650() => _i1.Intl.message(
        '\n        And a button component from somewhere\n        ',
        name: 'text_9650',
        args: [],
        desc: '');
    $d.text(text_9650());
    $d.open('d.button');
    $d.close();
  });
}
