import 'domino.dart';

Element div([content]) => new Element('div', content);

Element button(content, {EventHandler onClick}) =>
    new Element('button', [content, on('click', onClick)]);

Setter background(String value) => style('background', value);

typedef bool BoolFunction();

Setter clazzIf(condition, classTrue, [classFalse]) {
  if (condition is BoolFunction) {
    condition = condition();
  }
  if (condition == true) {
    return clazz(classTrue);
  }
  if (classFalse != null) return clazz(classFalse);
  return null;
}
