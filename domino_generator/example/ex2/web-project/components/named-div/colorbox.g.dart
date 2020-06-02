import 'package:domino/src/experimental/idom.dart' as _i0 show DomContext;
import 'package:intl/intl.dart' as _i1 show Intl;

void renderRedBox(_i0.DomContext $d) {
  $d.open('div');
  $d.attr('style', 'background-color: red; width: 10px; height: 10px');
  {
    String text_X_4b68ab38() =>
        _i1.Intl.message('X', name: 'text_X_4b68ab38', args: [], desc: '');
    $d.text(text_X_4b68ab38());
  }
  $d.close();
}

void renderBlueBox(_i0.DomContext $d) {
  $d.open('div');
  $d.attr('style', 'background-color: blue; width: 10px; height: 10px');
  {
    String text_O_c4694f2e() =>
        _i1.Intl.message('O', name: 'text_O_c4694f2e', args: [], desc: '');
    $d.text(text_O_c4694f2e());
  }
  $d.open('b');
  {
    String text_O_c4694f2e() =>
        _i1.Intl.message('O', name: 'text_O_c4694f2e', args: [], desc: '');
    $d.text(text_O_c4694f2e());
  }
  $d.close();
  $d.close();
}
