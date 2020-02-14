import 'package:test/test.dart';

import 'package:domino_generator/src/canonical.dart';

void main() {
  String c(String input, {bool wrapper = false}) {
    final parsed = parseToCanonical(input);
    if (wrapper) {
      return parsed.templates.map((elem) => elem.outerHtml).join('\n');
    } else {
      return parsed.templates.map((elem) => elem.innerHtml).join('\n');
    }
  }

  test('d-template name', () {
    expect(c('<d-template *="Name"><div>X</div></d-template>', wrapper: true),
        '<d-template *="Name"><div>X</div></d-template>');
  });

  test('wrap with d-template', () {
    expect(c('<div>X</div>', wrapper: true),
        '<d-template><div>X</div></d-template>');
  });

  test('d-for', () {
    expect(c('<div d-for="param in params">X</div>'),
        '<d-for *="param in params"><div>X</div></d-for>');
  });

  test('d-if', () {
    expect(
        c('<div d-if="param">X</div>'), '<d-if *="param"><div>X</div></d-if>');
    expect(c('<div d-if="param">X</div><b>B</b>'),
        '<d-if *="param"><div>X</div></d-if><b>B</b>');
  });

  test('d-else-if', () {
    expect(c('<div d-else-if="param">X</div>'),
        '<d-else-if *="param"><div>X</div></d-else-if>');
  });

  test('d-else', () {
    expect(c('<div d-else>X</div>'), '<d-else><div>X</div></d-else>');
  });

  test('d-for + d-if', () {
    expect(c('<div d-for="param in params" d-if="param.visible">X</div>'),
        '<d-for *="param in params"><d-if *="param.visible"><div>X</div></d-if></d-for>');
  });

  test('inlined key', () {
    expect(c('<div #kv>X</div>'), '<div d-key="\'kv\'">X</div>');
  });

  test('call external html', () {
    expect(c('<d-call *="package:x/x.html # Button">X</d-call>'),
        '<d-call d-library="package:x/x.g.dart" d-method="renderButton">X</d-call>');
  });

  test('call same library', () {
    expect(c('<d-call *="renderButton">X</d-call>'),
        '<d-call d-method="renderButton">X</d-call>');
  });

  test('call + call', () {
    expect(
        c('<d-call *="Button"></d-call><d-call *="X" ></d-call>'),
        '<d-call d-method="renderButton"></d-call>'
        '<d-call d-method="renderX"></d-call>');
  });

  test('call + if + call', () {
    expect(
        c('<d-call *if="true" *="Button"></d-call><d-call *="X"></d-call>'),
        '<d-if *="true"><d-call d-method="renderButton"></d-call></d-if>'
        '<d-call d-method="renderX"></d-call>');
  });
}
