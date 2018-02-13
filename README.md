# Domino

An experimental virtual dom library in Dart, which allows mixing DOM elements with components.

Main features:

- Virtual DOM nodes and stateful components can be mixed.
- Supports server-side rendering.

## Usage

A simple usage example:

````dart
import 'dart:html' as html;

import 'package:domino/domino.dart';
import 'package:domino/html_view.dart';
import 'package:domino/node_helpers.dart';

main() {
  registerHtmlView(html.querySelector('#main'), new SimpleComponent());
}

class SimpleComponent extends Component {
  int counter = 0;

  @override
  build(BuildContext context) {
    return [
      div(content: [
        div(content: 'Counter: $counter'),
        button(content: 'Increment', onClick: _onClick),
      ]),
    ];
  }

  void _onClick(_) {
    counter++;
  }
}
````
