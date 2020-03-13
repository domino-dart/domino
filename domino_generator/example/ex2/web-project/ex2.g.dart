import 'package:domino/src/experimental/idom.dart' as _i0 show DomContext;
import 'components/named-div/button.g.dart' as _i1 show button;
import 'components/named-div/colorbox.g.dart' as _i2 show red_box;

void ex2(_i0.DomContext $d) {
  $d.open('button');
  $d.text('\n        The best button\n    ');
  $d.close();
  _i1.button($d);
  _i2.red_box($d);
}
