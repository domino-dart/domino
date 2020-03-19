import 'package:domino/src/experimental/idom.dart' as _i0 show DomContext;
import 'components/named-div/button.g.dart' as _i1 show renderButton;
import 'components/named-div/colorbox.g.dart' as _i2
    show renderBlueBox, renderRedBox;

void renderEx3(
  _i0.DomContext $d, {
  Map<String, void Function(_i0.DomContext)> $dSlots,
}) {
  $dSlots ??= {};
  $d.open('button');
  $d.text('\n        The best button\n    ');
  $d.close();
  $dSlots[''] = (_i0.DomContext $d) {};
  _i1.renderButton($d, $dSlots: $dSlots);
  $dSlots[''] = (_i0.DomContext $d) {
    $d.text('\n        Here is an input field:\n        ');
    $d.open('input');
    $d.close();
    $d.text('\n        And a button component from somewhere\n        ');
/* d. means it should look at any namespace */
    $dSlots[''] = (_i0.DomContext $d) {};
    _i1.renderButton($d, $dSlots: $dSlots);
  };
  _i2.renderRedBox($d, $dSlots: $dSlots);
  $dSlots[''] = (_i0.DomContext $d) {
    $d.text('\n        Here is an input field:\n        ');
    $d.open('input');
    $d.close();
    $d.text('\n        And a button component from somewhere\n        ');
/* d. means it should look at any namespace */
    $dSlots[''] = (_i0.DomContext $d) {};
    _i1.renderButton($d, $dSlots: $dSlots);
  };
  _i2.renderBlueBox($d, $dSlots: $dSlots);
}
