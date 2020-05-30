import 'package:domino/src/experimental/idom.dart' as _i0 show DomContext;
import 'package:intl/intl.dart' as _i1 show Intl;
import 'components/named-div/button.g.dart' as _i2 show renderButton;
import 'components/named-div/colorbox.g.dart' as _i3 show renderRedBox;

void renderEx2(_i0.DomContext $d) {
  $d.open('button');
  String text_10490() => _i1.Intl.message('\n        The best button\n    ',
      name: 'text_10490', args: [], desc: '');
  $d.text(text_10490());
  $d.close();
  _i2.renderButton($d);
  _i3.renderRedBox($d);
}
