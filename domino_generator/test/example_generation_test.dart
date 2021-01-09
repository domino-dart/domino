import 'package:test/test.dart';

import '../example/ex1/generate_all.dart' as ex1a;
import '../example/ex1/generate_html.dart' as ex1h;
import '../example/ex2/generate_all.dart' as ex2a;
import '../example/ex3/generate_all.dart' as ex3a;
import '../example/ex3/generate_html.dart' as ex3h;

void main() {
  test('Example 1 code generation test', ex1a.main,
      timeout: Timeout(Duration(minutes: 1)));
  test('Example 1 html generation test', ex1h.main,
      timeout: Timeout(Duration(minutes: 1)));
  test('Example 2 code generation test', ex2a.main,
      timeout: Timeout(Duration(minutes: 1)));
  test('Example 3 code generation test', ex3a.main,
      timeout: Timeout(Duration(minutes: 1)));
  test('Example 3 html generation test', ex3h.main,
      timeout: Timeout(Duration(minutes: 1)));
}
