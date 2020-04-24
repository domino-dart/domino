import 'package:domino/src/experimental/idom.dart' as _i0 show DomContext;
import 'package:meta/meta.dart' as _i2 show required;
import 'ex1_model.dart' as _i1 show Example;

void renderEx1(
  _i0.DomContext $d, {

  /// Go recursive
  bool extra,
  @_i2.required _i1.Example obj,
}) {
  extra ??= false;
  $d.open('div', key: 'key1');
  $d.attr('title', 'Some help ${obj.name}.');
  $d.clazz('d_renderEx1');

  $d.text('Some ${obj.text} and ${obj.number}.');
  $d.close();
  if (obj.cond1) {
    $d.open('span', key: obj.number.toString());
    $d.clazz('d_renderEx1');

    $d.text('cond1');
    $d.close();
  } else if (obj.cond2 && extra) {
    $d.open('span');
    $d.clazz('d_renderEx1');

    $d.text('cond2');
    $d.close();
  } else {
    $d.open('span');
    $d.clazz('d_renderEx1');

    $d.text('cond3');
    $d.close();
  }
  $d.open('ul');
  $d.clazz('d_renderEx1');

  for (final item in obj.items) {
    if (item.visible) {
      $d.open('li');
      $d.clazz('d_renderEx1');

      $d.text('${item.label} ${obj.name}');
      $d.close();
    }
  }
  $d.close();
  if (extra) {
    renderEx1($d, obj: obj, extra: false);
  }
  renderEx2($d);
}

void renderEx2(_i0.DomContext $d) {
  $d.open('div');
  $d.clazz('d_renderEx2');

  $d.text('X');
  $d.close();
}
