import 'package:domino/src/experimental/idom.dart' as _i0 show DomContext;
import 'package:intl/intl.dart' as _i1 show Intl;

void renderRedBox(_i0.DomContext $d) {
  $d.open('div');
  $d.attr('style', 'background-color: red; width: 10px; height: 10px');
  String text_67739() => _i1.Intl.message('\n        X\n    ',
      name: 'text_67739', args: [], desc: '');
  $d.text(text_67739());
  $d.close();
}

void renderBlueBox(_i0.DomContext $d) {
  $d.open('div');
  $d.attr('style', 'background-color: blue; width: 10px; height: 10px');
  String text_52428() => _i1.Intl.message('\n        O\n    ',
      name: 'text_52428', args: [], desc: '');
  $d.text(text_52428());
  $d.close();
}
