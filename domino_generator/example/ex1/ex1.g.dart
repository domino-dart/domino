import 'package:domino/src/experimental/idom.dart' as _i0 show DomContext;
import 'package:intl/intl.dart' as _i3 show Intl;
import 'package:meta/meta.dart' as _i2 show required;
import 'ex1_model.dart' as _i1 show Example;

void renderEx1(
  _i0.DomContext $d, {
  @_i2.required _i1.Example obj,

  /// Go recursive
  bool extra,
}) {
  extra ??= false;
  $d.open('div', key: 'key1');
  $d.attr('title', 'Some help ${obj.name}.');
  {
    String text_Some_obj_text_35278f15(arg0, arg1) =>
        _i3.Intl.message('Some $arg0 and $arg1.',
            name: 'text_Some_obj_text_35278f15',
            args: [arg0, arg1],
            desc: '\${obj.text}\n\${obj.number}');
    $d.text(text_Some_obj_text_35278f15('${obj.text}', '${obj.number}'));
  }
  $d.close();
  if (obj.cond1) {
    $d.open('span', key: obj.number.toString());
    {
      String text_cond1_65176508() => _i3.Intl.message('cond1',
          name: 'text_cond1_65176508', args: [], desc: '');
      $d.text(text_cond1_65176508());
    }
    $d.close();
  } else if (obj.cond2 && extra) {
    $d.open('span');
    {
      String text_cond2_915c343c() => _i3.Intl.message('cond2',
          name: 'text_cond2_915c343c', args: [], desc: '');
      $d.text(text_cond2_915c343c());
    }
    $d.close();
  } else {
    $d.open('span');
    {
      String text_cond3_abfec480() => _i3.Intl.message('cond3',
          name: 'text_cond3_abfec480', args: [], desc: '');
      $d.text(text_cond3_abfec480());
    }
    $d.close();
  }
  $d.open('ul');
  for (final item in obj.items) {
    if (item.visible) {
      $d.open('li');
      $d.clazz('a');
      $d.clazz('x-${item.clazz}');
      {
        String text_item_label_obj_b0177529(arg0, arg1) =>
            _i3.Intl.message('$arg0 $arg1',
                name: 'text_item_label_obj_b0177529',
                args: [arg0, arg1],
                desc: '\${item.label}\n\${obj.name}');
        $d.text(text_item_label_obj_b0177529('${item.label}', '${obj.name}'));
      }
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
  {
    String text_X_4b68ab38() =>
        _i3.Intl.message('X', name: 'text_X_4b68ab38', args: [], desc: '');
    $d.text(text_X_4b68ab38());
  }
  $d.close();
}
