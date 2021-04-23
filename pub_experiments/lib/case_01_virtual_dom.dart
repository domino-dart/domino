import 'package:domino/domino.dart';
import 'package:domino/html_markup.dart';

import 'data.dart';

void main() {
  final tree = Element(
    'div',
    [
      ...data.tags.map(
        (tag) => Element(
          tag.href != null ? 'a' : 'span',
          [
            clazz('package-tag'),
            clazz(tag.status),
            attr('title', tag.title),
            attr('href', tag.href),
            tag.text,
          ],
        ),
      ),
    ],
  );

  final html = HtmlMarkupBuilder(indent: '  ').convert(tree);
  print(html);
}
