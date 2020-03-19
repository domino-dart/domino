import 'package:domino/src/experimental/idom.dart' as _i0 show DomContext;
import 'components/named-div/button.g.dart' as _i1 show renderButton;
import 'components/named-div/colorbox.g.dart' as _i2
    show renderBlueBox, renderRedBox;

void renderEx3(_i0.DomContext $d) {
  $d.open('button');
  $d.text('\n        The best button\n    ');
  $d.close();
  _i1.renderButton($d);
/* Error if uncommented
        Here is an input field:
        <input>
        And a button component from somewhere
        <d.button></d.button>
        */
  _i2.renderRedBox($d);
/* d. means it should look at any namespace */
  _i2.renderBlueBox($d, slot: (_i0.DomContext $d) {
    $d.text('\n        Here is an input field:\n        ');
    $d.open('input');
    $d.close();
    $d.text('\n        And a button component from somewhere\n        ');
    _i1.renderButton($d);
  });
}
