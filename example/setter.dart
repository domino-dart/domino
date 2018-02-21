import 'dart:html' as html;

import 'package:domino/src/setters.dart';
import 'package:domino/html_view.dart';
import 'package:domino/node_helpers.dart';

StyleSetter background(String value) => new StyleSetter('background', value);

main() {
  registerHtmlView(html.querySelector('#main'),
      (_) => div([background('red'), clazz('main', 'show', 'hello')]));
}
