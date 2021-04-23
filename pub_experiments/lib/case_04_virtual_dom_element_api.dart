import 'package:domino/domino.dart';
import 'package:domino/html_markup.dart';

import 'data.dart';

void main() {
  final tree = elem(
    'div',
    content: [
      ...data.tags.map(
        (tag) => elem(
          tag.href != null ? 'a' : 'span',
          classes: ['package-tag', tag.status],
          attrs: {
            'title': tag.title,
            'href': tag.href,
          },
          content: tag.text,
        ),
      ),
    ],
  );

  final html = HtmlMarkupBuilder(indent: '  ').convert(tree);
  print(html);
}

Element elem(
  String tag, {
  List<String?>? classes,
  Map<String, String?>? attrs,
  dynamic content,
}) {
  return Element(tag, [
    if (classes != null) ...classes.map((c) => clazz(c)),
    if (attrs != null) ...attrs.entries.map((a) => attr(a.key, a.value)),
    content,
  ]);
}
