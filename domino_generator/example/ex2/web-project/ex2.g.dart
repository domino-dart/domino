import 'package:domino/src/experimental/idom.dart' as _i0 show DomContext;
import 'components/named-div/button.g.dart' as _i1 show button;
import 'components/named-div/colorbox.g.dart' as _i2 show red_box;

void ex2(
  _i0.DomContext $d, {
  Map<String, void Function(_i0.DomContext)> $dSlots,
}) {
  $dSlots ??= {};
  $d.open('button');
  $d.text('\n        The best button\n    ');
  $d.close();
  $dSlots[''] = (_i0.DomContext $d) {};
  _i1.button($d, $dSlots: $dSlots);
  $dSlots[''] = (_i0.DomContext $d) {};
  _i2.red_box($d, $dSlots: $dSlots);
}
