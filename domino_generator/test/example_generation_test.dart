import 'package:test/test.dart';

import '../example/ex1/generate_all.dart' as ex1A;
import '../example/ex1/generate_html.dart' as ex1H;
import '../example/ex2/generate_all.dart' as ex2A;
import '../example/ex3/generate_all.dart' as ex3A;
import '../example/ex3/generate_html.dart' as ex3H;

void main() {
  test('Example 1 code generation test', ex1A.main,
      timeout: Timeout(Duration(minutes: 1)));
  test('Example 1 html generation test', ex1H.main,
      timeout: Timeout(Duration(minutes: 1)));
  test('Example 2 code generation test', ex2A.main,
      timeout: Timeout(Duration(minutes: 1)));
  test('Example 3 code generation test', ex3A.main,
      timeout: Timeout(Duration(minutes: 1)));
  test('Example 3 html generation test', ex3H.main,
      timeout: Timeout(Duration(minutes: 1)));
}
