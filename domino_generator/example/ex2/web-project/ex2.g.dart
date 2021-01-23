import 'package:domino/src/experimental/idom.dart' as _i1;
import 'components/named-div/button.g.dart' as _i2;
import 'components/named-div/colorbox.g.dart' as _i3;

void renderEx2(_i1.DomContext $d) {
  $d.open('button');
  $d.text('\n        The best button\n    ');
  $d.close();
  _i2.renderButton($d);
  _i3.renderRedBox($d);
}
