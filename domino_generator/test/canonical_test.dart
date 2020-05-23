import 'package:test/test.dart';

import 'package:domino_generator/src/canonical.dart';

void main() {
  String c(String input, {bool wrapped = false}) {
    final parsed = parseToCanonical(wrapped ? input : '<test>$input</test>');
    return parsed.templates.map((elem) {
      final x = elem.toXmlString();
      return wrapped
          ? x
          : x
              .replaceFirst(
                  '<d:template d:name="test" d:method-name="renderTest">', '')
              .replaceFirst('</d:template>', '');
    }).join('\n');
  }

  test('template method-name', () {
    expect(
        c('<d:template d:name="Name"><div>X</div></d:template>', wrapped: true),
        '<d:template d:name="Name" d:method-name="renderName"><div>X</div></d:template>');
  });

  test('wrap with d-template', () {
    expect(c('<div>X</div>', wrapped: true),
        '<d:template d:name="div" d:method-name="renderDiv">X</d:template>');
  });

  test('d:for', () {
    expect(c('<div d:for="param in params">X</div>'),
        '<d:for d:expr="param in params"><div>X</div></d:for>');
  });

  test('d:if', () {
    expect(c('<div d:if="param">X</div>'),
        '<d:if d:expr="param"><div>X</div></d:if>');
    expect(c('<div d:if="param">X</div><b>B</b>'),
        '<d:if d:expr="param"><div>X</div></d:if><b>B</b>');
  });

  test('d:else-if', () {
    expect(c('<div d:else-if="param">X</div>'),
        '<d:else-if d:expr="param"><div>X</div></d:else-if>');
  });

  test('d:else', () {
    expect(c('<div d:else="">X</div>'), '<d:else><div>X</div></d:else>');
  });

  test('d:for + d:if', () {
    expect(
        c('<div d:for="param in params" d:if="param.visible">X</div>'),
        '<d:for d:expr="param in params">'
        '<d:if d:expr="param.visible"><div>X</div>'
        '</d:if>'
        '</d:for>');
  });

  test('call external html', () {
    expect(c('<d:call d:expr="package:x/x.html # Button">X</d:call>'),
        '<d:call d:library="package:x/x.g.dart" d:method="renderButton"><d:call-slot d:name="slot">X</d:call-slot></d:call>');
  });

  test('call same library', () {
    expect(c('<d:call d:expr="renderButton">X</d:call>'),
        '<d:call d:method="renderButton"><d:call-slot d:name="slot">X</d:call-slot></d:call>');
  });

  test('call + call', () {
    expect(
        c('<d:call d:expr="Button" /><d:call d:expr="X" />'),
        '<d:call d:method="renderButton"/>'
        '<d:call d:method="renderX"/>');
  });

  test('call + if + call', () {
    expect(
        c('<d:call d:if="true" d:expr="Button"></d:call><d:call d:expr="X"></d:call>'),
        '<d:if d:expr="true"><d:call d:method="renderButton"></d:call></d:if>'
        '<d:call d:method="renderX"></d:call>');
  });

  test('namespaced component', () {
    expect(c('<div xmlns:x="./other/x.html"><x:component /></div>'),
        '<div xmlns:x="./other/x.html"><d:call d:library="./other/x.g.dart" d:method="renderComponent"/></div>');
  });

  test('namespaced component with default slot', () {
    expect(
        c('<div xmlns:x="./other/x.html"><x:component><span>Inside</span></x:component></div>'),
        '<div xmlns:x="./other/x.html">'
        '<d:call d:library="./other/x.g.dart" d:method="renderComponent">'
        '<d:call-slot d:name="slot">'
        '<span>Inside</span>'
        '</d:call-slot>'
        '</d:call>'
        '</div>');
  });
}
