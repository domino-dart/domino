import 'package:domino/src/experimental/idom.dart' as _i0 show DomContext;

void renderMain(
  _i0.DomContext $d, {
  clickFun,
  String clickName,
}) {
  $d.open('div');
  $d.clazz('templates_renderMain');

  $d.open('button');
  $d.attr('id', 'clickButton');
  $d.event('click', fn: clickFun);
  $d.clazz('templates_renderMain');

  $d.text('\n        ${clickName}\n    ');
  $d.close();
  $d.open('input');
  $d.clazz('templates_renderMain');

  $d.close();
  $d.close();
}
