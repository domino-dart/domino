import 'package:domino/src/experimental/idom.dart' as _i0
    show DomContext, SlotFn;

void renderBestButton(
  _i0.DomContext $d, {
  events,
  String boldText,
  _i0.SlotFn slot,
}) {
  $d.open('div');
  for (final key in events.keys) {
    $d.event(key, fn: events[key]);
  }

  $d.clazz('templates_renderBestButton');

  $d.text('\n        The mighty click area with ');
  $d.open('b');
  $d.clazz('templates_renderBestButton');

  $d.text('${boldText}');
  $d.close();
  $d.text(':\n        ');
  slot($d);
  $d.close();
}
