import 'package:test/test.dart';

import 'package:domino/src/flat_classes.dart';

void main() {
  group('flat classes fn', () {
    test('null', () {
      expect(flatClasses(null), isNull);
    });

    test('string', () {
      expect(flatClasses('abc'), ['abc']);
    });

    test('List of stirng', () {
      expect(flatClasses(['ab', 'cd', null]), ['ab', 'cd']);
    });

    test('List of lists', () {
      expect(flatClasses(['a', ['b', null, 'c'], 'd']), ['a', 'b', 'c', 'd']);
    });
  });
}
