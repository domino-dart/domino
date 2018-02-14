import 'dart:html' as html;

import 'package:domino/domino.dart';
import 'package:domino/html_view.dart';
import 'package:domino/node_helpers.dart';

StyleSetter background(String value) => new StyleSetter('background', value);

main() {
  registerHtmlView(html.querySelector('#main'),
      (_) => div(set: [background('red'), clazz('main', 'show', 'hello')]));
}
