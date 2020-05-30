import 'package:domino/src/experimental/idom.dart' as _i0 show DomContext;
import 'package:intl/intl.dart' as _i1 show Intl;

void renderButton(_i0.DomContext $d) {
  String text_73072() => _i1.Intl.message('\n    Named\n    ',
      name: 'text_73072', args: [], desc: '');
  $d.text(text_73072());
  $d.open('b');
  String text_7356() =>
      _i1.Intl.message('Button', name: 'text_7356', args: [], desc: '');
  $d.text(text_7356());
  $d.close();
}
