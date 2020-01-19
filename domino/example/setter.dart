import 'dart:html' as html;

import 'package:domino/html_view.dart';
import 'package:domino/helpers.dart';

main() {
  registerHtmlView(html.querySelector('#main'),
      (_) => div([background('red'), clazz('main', 'show', 'hello')]));
}
