import 'package:domino/src/experimental/idom.dart' as _i0 show DomContext;
import 'button.g.dart' as _i1 show renderBestButton;

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

  $d.text('\n            ${clickName}\n        ');
  $d.close();
  $d.open('input');
  $d.clazz('templates_renderMain');

  $d.close();
  _i1.renderBestButton($d, slot: (_i0.DomContext $d) {
    $d.open('b');
    $d.clazz('templates_renderMain');

    $d.text('Slot text');
    $d.close();
  }, boldText: 'Boldy texty', events: {'click': clickFun});
  $d.close();
}
