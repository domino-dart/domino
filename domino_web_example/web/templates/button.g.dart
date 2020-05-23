import 'package:domino/src/experimental/idom.dart' as _i0
    show DomContext, SlotFn;

void renderBestButton(
  _i0.DomContext $d, {
  _i0.SlotFn slot,
  String boldText,
  events,
}) {
  $d.open('div');
  $d.text('\n        The mighty click area with ');
  $d.open('b');
  $d.text('${boldText}');
  $d.close();
  $d.text(':\n        ');
  if (slot != null) {
    slot($d);
  }
  $d.close();
}
