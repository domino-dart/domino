// ignore: import_of_legacy_library_into_null_safe
import 'package:domino/src/experimental/idom.dart' as _i1;
import './components/named-div/button.g.dart' as _i2;
import './components/named-div/library.dart' as _i3;

void renderEx3(_i1.DomContext $d) {
  $d.open('button');
  $d.text('\n        The best button\n    ');
  $d.close();
  _i2.renderButton($d);
  _i3.renderRedBox($d);
  _i3.renderBlueBox($d, slot: (_i1.DomContext $d) {
    $d.text('\n        Here is an input field:\n        ');
    $d.open('input');
    $d.close();
    $d.text('\n        And a button component from somewhere\n        ');
    $d.open('d.button');
    $d.close();
  });
}
