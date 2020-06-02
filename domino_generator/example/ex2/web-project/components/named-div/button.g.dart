import 'package:domino/src/experimental/idom.dart' as _i0 show DomContext;
import 'package:intl/intl.dart' as _i1 show Intl;

void renderButton(_i0.DomContext $d) {
  {
    String text_Named_8605605a() => _i1.Intl.message('Named',
        name: 'text_Named_8605605a', args: [], desc: '');
    $d.text(text_Named_8605605a());
  }
  $d.open('b');
  {
    String text_Button_707eab0c() => _i1.Intl.message('Button',
        name: 'text_Button_707eab0c', args: [], desc: '');
    $d.text(text_Button_707eab0c());
  }
  $d.close();
}
