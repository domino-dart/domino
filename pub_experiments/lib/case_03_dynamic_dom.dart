import 'package:domino/src/experimental/ddom.dart';
import 'package:domino/src/experimental/ddom_html_markup.dart';

import 'data.dart';

void main() {
  final tree = DElem(
    'div',
    children: [
      ...data.tags.map(
        (tag) => DElem(
          tag.href != null ? 'a' : 'span',
          classes: DStringList(values: [
            'package-tag',
            if (tag.status != null) tag.status!,
          ]),
          attrs: DStringMap(fns: {
            'href': () => tag.href != null ? tag.href! : null,
            'title': () => tag.title != null ? tag.title! : null,
          }),
          children: [DText(tag.text)],
        ),
      ),
    ],
  );
  final html = HtmlBuilderVisitor(indent: '\n').convert(tree);
  print(html);
}
