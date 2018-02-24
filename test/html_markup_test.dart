import 'package:test/test.dart';

import 'package:domino/domino.dart';
import 'package:domino/html_markup.dart';

void main() {
  group('HTML markup tests', () {
    final builder = new HtmlMarkupBuilder(indent: '  ');

    test('Simple DIV', () {
      expect(
          builder.convert(new Element(
            'div',
            [attr('attr', 'value'), clazz('c1', 'c2'), style('width', '100%')],
          )),
          '<div class="c1 c2" style="width: 100%" attr="value" />');
    });

    test('Hierarchy', () {
      expect(
          builder.convert(new Element('div', [
            'a',
            new Element('span', 'in-span'),
            'b',
          ])),
          '<div>\n'
          '  a\n'
          '  <span>\n'
          '    in-span\n'
          '  </span>\n'
          '  b\n'
          '</div>');
    });
  });
}
