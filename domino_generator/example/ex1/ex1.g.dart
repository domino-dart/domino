import 'package:domino/src/experimental/idom.dart' as _i1;
import 'ex1_model.dart' as _i2;

void renderEx1(_i1.DomContext $d,
    {required _i2.Example obj,

    /// Go recursive
    bool? extra}) {
  extra ??= false;
  $d.open('div', key: 'key1');
  $d.attr('title', 'Some help ${obj.name}.');
  $d.text('Some ${obj.text} and ${obj.number}.');
  $d.close();
  if (obj.cond1) {
    $d.open('span', key: obj.number.toString());
    $d.text('cond1');
    $d.close();
  } else if (obj.cond2 && extra) {
    $d.open('span');
    $d.text('cond2');
    $d.close();
  } else {
    $d.open('span');
    $d.text('cond3');
    $d.close();
  }
  $d.open('ul');
  for (final item in obj.items) {
    if (item.visible) {
      $d.open('li');
      $d.clazz('a');
      $d.clazz('x-${item.clazz}');
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

void renderEx2(_i1.DomContext $d) {
  $d.open('div');
  $d.text('X');
  $d.close();
}
