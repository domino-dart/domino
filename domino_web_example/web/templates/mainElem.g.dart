import 'package:domino/src/experimental/idom.dart' as _i0 show DomContext;
import 'button.g.dart' as _i2 show renderBestButton;
import 'human.dart' as _i1 show Human;

void renderMain(
  _i0.DomContext $d, {
  _i1.Human human,
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
  $d.attr('width', '${human.age}');
  $d.attr('type', '${human.name}');
  $d.clazz('templates_renderMain');

  $d.close();
  $d.open('input');
  {
    final elem = $d.element;
    elem.value = human.name;
    $d.event('input', fn: (event) {
      human.name = elem.value;
    });
    $d.event('change', fn: (event) {
      human.name = elem.value;
    });
  }
  $d.clazz('templates_renderMain');

  $d.close();
  $d.open('input');
  {
    final elem = $d.element;
    elem.value = human.location;
    $d.event('input', fn: (event) {
      human.location = elem.value;
    });
    $d.event('change', fn: (event) {
      human.location = elem.value;
    });
  }
  $d.clazz('templates_renderMain');

  $d.close();
  _i2.renderBestButton($d, slot: (_i0.DomContext $d) {
    $d.open('b');
    $d.clazz('templates_renderMain');

    $d.text('Slot text');
    $d.close();
  }, boldText: 'Boldy texty', events: {'click': clickFun});
  $d.close();
}
