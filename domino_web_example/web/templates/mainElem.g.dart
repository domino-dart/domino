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
    final elem = $d.element;
    final atrBind = _i0.BindedVar<String>(() => elem.value, (String val) {
      elem.value = val;
    });
    final varBind = _i0.BindedVar<String>(() => in1val, (val) {
      in1val = val;
    });
    atrBind.triggerListenOn(elem.onInput);
    atrBind.triggerListenOn(elem.onChange);
    atrBind.triggerListenOn(Stream.periodic(Duration(milliseconds: 50)));
    varBind.triggerListenOn(Stream.periodic(Duration(milliseconds: 50)));
    atrBind.bind(varBind);
  }
  $d.clazz('templates_renderMain');

  $d.close();
  $d.open('input');
  {
    final elem = $d.element;
    final atrBind = _i0.BindedVar<String>(() => elem.value, (String val) {
      elem.value = val;
    });
    final varBind = _i0.BindedVar<String>(() => in1val, (val) {
      in1val = val;
    });
    atrBind.triggerListenOn(elem.onInput);
    atrBind.triggerListenOn(elem.onChange);
    atrBind.triggerListenOn(Stream.periodic(Duration(milliseconds: 50)));
    varBind.triggerListenOn(Stream.periodic(Duration(milliseconds: 50)));
    atrBind.bind(varBind);
  }
  {
    final elem = $d.element;
    final atrBind =
        _i0.BindedVar<String>(() => elem.attributes['type'], (String val) {
      elem.attributes['type'] = val;
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
