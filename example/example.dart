import 'dart:html' as html;

import 'package:domino/domino.dart';
import 'package:domino/html_view.dart';
import 'package:domino/helpers.dart';

main() {
  registerHtmlView(html.querySelector('#main'), new SimpleComponent());
}

class SimpleComponent extends Component {
  int counter = 0;

  @override
  build(BuildContext context) {
    return [
      div([
        div('Counter: $counter'),
        button([#btn, 'Increment'], onClick: _onClick),
      ]),
    ];
  }

  void _onClick(_) {
    counter++;
  }
}
