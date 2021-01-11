import 'dart:html' as html;

import 'package:domino/domino.dart';
import 'package:domino/html_view.dart';
import 'package:domino/helpers.dart';

void main() {
  registerHtmlView(html.querySelector('#main'), SimpleComponent());
}

class SimpleComponent extends Component {
  int counter = 0;

  @override
  dynamic build(BuildContext context) {
    return [
      div([
        div('Counter: $counter'),
        button([#btn, 'Increment'], onClick: _onClick),
      ]),
    ];
  }

  void _onClick() {
    counter++;
  }
}
