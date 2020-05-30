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
  String text_34430(arg0, arg1) => _i3.Intl.message('Some $arg0 and $arg1.',
      name: 'text_34430',
      args: [arg0, arg1],
      desc: '\${obj.text}\n\${obj.number}');
  $d.text(text_34430('${obj.text}', '${obj.number}'));
  $d.close();
  if (obj.cond1) {
    $d.open('span', key: obj.number.toString());
    String text_20917() =>
        _i3.Intl.message('cond1', name: 'text_20917', args: [], desc: '');
    $d.text(text_20917());
    $d.close();
  } else if (obj.cond2 && extra) {
    $d.open('span');
    String text_44084() =>
        _i3.Intl.message('cond2', name: 'text_44084', args: [], desc: '');
    $d.text(text_44084());
    $d.close();
  } else {
    $d.open('span');
    String text_43298() =>
        _i3.Intl.message('cond3', name: 'text_43298', args: [], desc: '');
    $d.text(text_43298());
    $d.close();
  }
  $d.open('ul');
  for (final item in obj.items) {
    if (item.visible) {
      $d.open('li');
      $d.clazz('a');
      $d.clazz('x-${item.clazz}');
      String text_84148(arg0, arg1) => _i3.Intl.message('$arg0 $arg1',
          name: 'text_84148',
          args: [arg0, arg1],
          desc: '\${item.label}\n\${obj.name}');
      $d.text(text_84148('${item.label}', '${obj.name}'));
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
  String text_88810() =>
      _i3.Intl.message('X', name: 'text_88810', args: [], desc: '');
  $d.text(text_88810());
  $d.close();
}
