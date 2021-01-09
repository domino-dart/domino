import 'package:domino/src/experimental/idom.dart' as _i0 show DomContext;
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
    String text_Some_obj_text_35278f15($arg0, $arg1) =>
        (_$strings[r'text_Some_obj_text_35278f15']
                    .containsKey($d.globals['locale'])
                ? _$strings[r'text_Some_obj_text_35278f15']
                    [$d.globals['locale']]
                : _$strings[r'text_Some_obj_text_35278f15'][''])
            .toString()
            .replaceAll(r'$arg0', $arg0.toString())
            .replaceAll(r'$arg1', $arg1.toString());
    $d.text(text_Some_obj_text_35278f15(obj.text, obj.number));
  }
  $d.close();
  if (obj.cond1) {
    $d.open('span', key: obj.number.toString());
    {
      String text_cond1_65176508() =>
          (_$strings[r'text_cond1_65176508'].containsKey($d.globals['locale'])
                  ? _$strings[r'text_cond1_65176508'][$d.globals['locale']]
                  : _$strings[r'text_cond1_65176508'][''])
              .toString();
      $d.text(text_cond1_65176508());
    }
    $d.close();
  } else if (obj.cond2 && extra) {
    $d.open('span');
    {
      String text_cond2_915c343c() =>
          (_$strings[r'text_cond2_915c343c'].containsKey($d.globals['locale'])
                  ? _$strings[r'text_cond2_915c343c'][$d.globals['locale']]
                  : _$strings[r'text_cond2_915c343c'][''])
              .toString();
      $d.text(text_cond2_915c343c());
    }
    $d.close();
  } else {
    $d.open('span');
    {
      String text_cond3_abfec480() =>
          (_$strings[r'text_cond3_abfec480'].containsKey($d.globals['locale'])
                  ? _$strings[r'text_cond3_abfec480'][$d.globals['locale']]
                  : _$strings[r'text_cond3_abfec480'][''])
              .toString();
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
        String text_item_label_obj_b0177529($arg0, $arg1) =>
            (_$strings[r'text_item_label_obj_b0177529']
                        .containsKey($d.globals['locale'])
                    ? _$strings[r'text_item_label_obj_b0177529']
                        [$d.globals['locale']]
                    : _$strings[r'text_item_label_obj_b0177529'][''])
                .toString()
                .replaceAll(r'$arg0', $arg0.toString())
                .replaceAll(r'$arg1', $arg1.toString());
        $d.text(text_item_label_obj_b0177529(item.label, obj.name));
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
        (_$strings[r'text_X_4b68ab38'].containsKey($d.globals['locale'])
                ? _$strings[r'text_X_4b68ab38'][$d.globals['locale']]
                : _$strings[r'text_X_4b68ab38'][''])
            .toString();
    $d.text(text_X_4b68ab38());
  }
  $d.close();
}

const _$strings = {
  'text_Some_obj_text_35278f15': {
    '_params': r'{$arg0: obj.text, $arg1: obj.number}',
    '': r'Some $arg0 and $arg1.',
  },
  'text_cond1_65176508': {
    '_params': r'{}',
    '': r'cond1',
  },
  'text_cond2_915c343c': {
    '_params': r'{}',
    '': r'cond2',
  },
  'text_cond3_abfec480': {
    '_params': r'{}',
    '': r'cond3',
  },
  'text_item_label_obj_b0177529': {
    '_params': r'{$arg0: item.label, $arg1: obj.name}',
    '': r'$arg0 $arg1',
  },
  'text_X_4b68ab38': {
    '_params': r'{}',
    '': r'X',
  },
};
