import 'package:test/test.dart';

import 'package:domino/src/experimental/ddom.dart';
import 'package:domino/src/experimental/ddom_html_markup.dart';

void main() {
  group('HTML markup tests', () {
    final builder = HtmlBuilderVisitor(indent: '  ');

    test('Simple DIV', () {
      expect(
          builder.convert(DElem(
            'div',
            classes: DStringList(values: {'c1', 'c2'}),
            attrs: DStringMap(values: {'attr': 'value'}),
            styles: DStringMap(values: {'width': '100%'}),
          )),
          '<div class="c1 c2" style="width: 100%" attr="value" />');
    });

    test('Hierarchy', () {
      expect(
          builder.convert(DElem('div', children: [
            DText('a'),
            DElem('span', children: [DText('in-span')]),
            DText('b'),
          ])),
          '<div>a  <span>in-span  </span>b\n'
          '</div>');
    });
  });
}
