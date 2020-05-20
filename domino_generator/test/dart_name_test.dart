import 'package:test/test.dart';

import 'package:domino_generator/src/canonical.dart';

void main() {
  test('d: prefix passthrough', () {
    expect(dartName('d:*_abc/123'), '*_abc/123');
  });

  test('snake_case', () {
    expect(dartName('snake_case'), 'snakeCase');
    expect(dartName('snake_case_v1'), 'snakeCaseV1');
  });

  test('unprefixed lowerCamelCase', () {
    expect(dartName('lowerCamelCase'), 'lowerCamelCase');
    expect(dartName('lowerCamelCaseV1'), 'lowerCamelCaseV1');
  });

  test('prefixed lowerCamelCase', () {
    expect(dartName('lowerCamelCase', prefix: 'p'), 'pLowerCamelCase');
    expect(dartName('lowerCamelCase', prefix: 'lower'), 'lowerCamelCase');
  });

  test('unprefixed CamelCase', () {
    expect(dartName('CamelCase'), 'camelCase');
    expect(dartName('CamelCaseAST'), 'camelCaseAst');
  });

  test('prefixed CamelCase', () {
    expect(dartName('CamelCase', prefix: 'p'), 'pCamelCase');
  });

  test('dashed-name', () {
    expect(dartName('dashed-name'), 'dashedName');
  });
}
