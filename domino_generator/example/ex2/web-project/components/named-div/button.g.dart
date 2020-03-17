import 'package:domino/src/experimental/idom.dart' as _i0 show DomContext;

void button(
  _i0.DomContext $d, {
  Map<String, void Function(_i0.DomContext)> $dSlots,
}) {
  $dSlots ??= {};
  $d.text('\n    Named\n    ');
  $d.open('b');
  $d.text('Button');
  $d.close();
}
