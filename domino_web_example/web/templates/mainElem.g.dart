import 'package:domino/src/experimental/idom.dart' as _i0
    show BindedVar, DomContext;
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

  var in1val;
  {
    final atrBind = _i0.BindedVar<String>(() => $d.element.value, (String val) {
      $d.element.value = val;
    });
    final varBind = _i0.BindedVar<String>(() => in1val, (val) {
      in1val = val;
    });
    atrBind.triggerListenOn($d.element.onInput);
    atrBind.triggerListenOn($d.element.onChange);
    atrBind.triggerListenOn(Stream.periodic(Duration(milliseconds: 50)));
    varBind.triggerListenOn(Stream.periodic(Duration(milliseconds: 50)));
    atrBind.bind(varBind);
  }
  $d.clazz('templates_renderMain');

  $d.close();
  $d.open('input');
  {
    final atrBind = _i0.BindedVar<String>(() => $d.element.value, (String val) {
      $d.element.value = val;
    });
    final varBind = _i0.BindedVar<String>(() => in1val, (val) {
      in1val = val;
    });
    atrBind.triggerListenOn($d.element.onInput);
    atrBind.triggerListenOn($d.element.onChange);
    atrBind.triggerListenOn(Stream.periodic(Duration(milliseconds: 50)));
    varBind.triggerListenOn(Stream.periodic(Duration(milliseconds: 50)));
    atrBind.bind(varBind);
  }
  {
    final atrBind = _i0.BindedVar<String>(() => $d.element.attributes['type'],
        (String val) {
      $d.element.attributes['type'] = val;
    });
    atrBind.listenOn(
        Stream.periodic(Duration(milliseconds: 50), (tick) => in1val));
  }
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
