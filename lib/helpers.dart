import 'domino.dart';

Element div([content]) => Element('div', content);
Element span([content]) => Element('span', content);

Element button(content, {Function onClick}) =>
    Element('button', [content, on('click', onClick)]);

Setter background(String value) => style('background', value);

clazzIf(
  /* bool fn() | bool */ condition,
  /* String | List<String> */ then, {
  /* String | List<String> */ orElse,
}) =>
    addIf(
      condition,
      () => clazz(then),
      orElse: () => clazz(orElse),
    );
