import 'domino.dart';

Element div([content]) => new Element('div', content);

Element button(content, {EventHandler onClick}) =>
    new Element('button', [content, on('click', onClick)]);

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
