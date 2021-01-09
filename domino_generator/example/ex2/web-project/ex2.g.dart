import 'package:domino/src/experimental/idom.dart' as _i0 show DomContext;
import 'components/named-div/button.g.dart' as _i1 show renderButton;
import 'components/named-div/colorbox.g.dart' as _i2 show renderRedBox;

void renderEx2(_i0.DomContext $d) {
  $d.open('button');
  $d.text('The best button');
  $d.close();
  _i1.renderButton($d);
  _i2.renderRedBox($d);
}
