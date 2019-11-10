import 'package:test/test.dart';

import 'package:domino/src/_unfold.dart';

void main() {
  group('flat classes fn', () {
    test('null', () {
      expect(unfold(null), isEmpty);
    });

    test('string', () {
      expect(unfold('abc'), ['abc']);
    });

    test('List of string', () {
      expect(unfold(['ab', 'cd', null]), ['ab', 'cd']);
    });

    test('List of lists', () {
      expect(
          unfold([
            'a',
            ['b', null, 'c'],
            'd'
          ]),
          ['a', 'b', 'c', 'd']);
    });
  });
}
