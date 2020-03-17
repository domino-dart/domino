import 'package:domino/src/experimental/idom.dart' as _i0 show DomContext;

void red_box(
  _i0.DomContext $d, {
  Map<String, void Function(_i0.DomContext)> $dSlots,
}) {
  $dSlots ??= {};
  $d.open('div');
  $d.attr('style', 'background-color: red; width: 10px; height: 10px');
  $d.text('\n        X\n    ');
  $d.close();
}

void blue_box(
  _i0.DomContext $d, {
  Map<String, void Function(_i0.DomContext)> $dSlots,
}) {
  $dSlots ??= {};
  $d.open('div');
  $d.attr('style', 'background-color: blue; width: 10px; height: 10px');
  $d.text('\n        O\n    ');
  $d.close();
}
