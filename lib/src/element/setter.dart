part of domino.element;

abstract class Setter {}

class StyleSetter implements Setter {
  final String name;

  final String value;

  const StyleSetter(this.name, this.value);
}

StyleSetter style(String name, String value) => new StyleSetter(name, value);

class AttrSetter implements Setter {
  final String name;

  final String value;

  const AttrSetter(this.name, this.value);
}

AttrSetter attr(String name, String value) => new AttrSetter(name, value);

AttrSetter id(String id) => new AttrSetter('id', id);

class ClassAdder implements Setter {
  final List<String> clazzes;

  ClassAdder(class1,
      [String class2, String class3, String class4, String class5])
      : clazzes = <String>[] {
    if (class1 != null) {
      if (class1 is String)
        clazzes.add(class1);
      else if (class1 is List<String>) clazzes.addAll(class1);
    }
    if (class2 != null) clazzes.add(class2);
    if (class3 != null) clazzes.add(class3);
    if (class4 != null) clazzes.add(class4);
    if (class5 != null) clazzes.add(class5);
  }
}

ClassAdder clazz(class1,
        [String class2, String class3, String class4, String class5]) =>
    new ClassAdder(class1, class2, class3, class4, class5);

typedef bool BoolFunction();

ClassAdder clazzWhen(condition,
    [class1, String class2, String class3, String class4, String class5]) {
  if (condition is BoolFunction) {
    condition = condition();
  }
  if (condition) return new ClassAdder(class1, class2, class3, class4, class5);
  return new ClassAdder(null);
}

ClassAdder clazzIf(condition, classTrue, [classFalse]) {
  if (condition is BoolFunction) {
    condition = condition();
  }
  if (condition) return new ClassAdder(classTrue);
  return new ClassAdder(classFalse);
}

class EventSetter implements Setter {
  final String event;

  final EventHandler handler;

  const EventSetter(this.event, this.handler);
}

EventSetter on(String event, EventHandler handler) =>
    new EventSetter(event, handler);
