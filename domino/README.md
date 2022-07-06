# Domino

An experimental virtual dom library in Dart, which allows mixing DOM elements with components.

Main features:

- Virtual DOM nodes and stateful components can be mixed.
- Supports server-side rendering.

[link](/x)

## Usage

A simple usage example:

````dart
import 'dart:html' as html;

import 'package:domino/domino.dart';
import 'package:domino/html_view.dart';
import 'package:domino/helpers.dart';

main() {
  registerHtmlView(html.querySelector('#main'), SimpleComponent());
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
````

## Links

- [source code][source]
- contributors:
    - [István Soós][isoos]
    - [Teja][tejainece]

[source]: https://github.com/isoos/domino
[isoos]: https://github.com/isoos
[tejainece]: https://github.com/tejainece
