import 'dart:html' as html;

import 'package:domino/html_view.dart';
import 'package:domino/helpers.dart';

void main() {
  registerHtmlView(html.querySelector('#main'),
      (_) => div([background('red'), clazz('main', 'show', 'hello')]));
}
