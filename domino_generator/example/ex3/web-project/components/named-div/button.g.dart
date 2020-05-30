import 'package:domino/src/experimental/idom.dart' as _i0 show DomContext;
import 'package:intl/intl.dart' as _i1 show Intl;

void renderButton(_i0.DomContext $d) {
  String text_48218() => _i1.Intl.message('\n    Named\n    ',
      name: 'text_48218', args: [], desc: '');
  $d.text(text_48218());
  $d.open('b');
  String text_75029() =>
      _i1.Intl.message('Button', name: 'text_75029', args: [], desc: '');
  $d.text(text_75029());
  $d.close();
}
