import 'package:domino/src/experimental/idom.dart' as _i0 show DomContext;

void renderMain(
  _i0.DomContext $d, {
  String clickName,
}) {
  $d.open('div');
  $d.open('button');
  $d.attr('id', 'clickButton');
  $d.attr('onclick', 'betterAlert(\'hello\');');
  $d.text('\n        ${clickName}\n    ');
  $d.close();
  $d.open('input');
  $d.close();
  $d.close();
}
