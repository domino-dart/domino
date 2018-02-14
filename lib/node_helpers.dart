import 'domino.dart';

/// Creates a <div> Element.
Element div({
  /* List<Setter> | Setter */ set,
  Map<String, String> attrs,
  Map<String, String> styles,
  List<String> classes,
  /* List, Component, Node, BuildFn, ... */ dynamic content,
  Map<String, EventHandler> events,
  dynamic key,
  AfterCallback afterInsert,
  AfterCallback afterUpdate,
  AfterCallback afterRemove,
}) =>
    _elem('div', set, attrs, styles, classes, content, events, key, afterInsert,
        afterUpdate, afterRemove);

Element button({
  /* List<Setter> | Setter */ set,
  Map<String, String> attrs,
  Map<String, String> styles,
  List<String> classes,
  /* List, Component, Node, BuildFn, ... */ dynamic content,
  Map<String, EventHandler> events,
  dynamic key,
  AfterCallback afterInsert,
  AfterCallback afterUpdate,
  AfterCallback afterRemove,
  EventHandler onClick,
}) =>
    _elem('button', set, attrs, styles, classes, content, events, key,
        afterInsert, afterUpdate, afterRemove)
      ..onClick(onClick);

Element br() => new Element('br');

Element _elem(
  String tag,
  List<Setter> set,
  Map<String, String> attrs,
  Map<String, String> styles,
  List<String> classes,
  dynamic content,
  Map<String, EventHandler> events,
  dynamic key,
  AfterCallback afterInsert,
  AfterCallback afterUpdate,
  AfterCallback afterRemove,
) =>
    new Element(
      tag,
      attrs: attrs,
      styles: styles,
      classes: classes,
      content: content,
      events: events,
      key: key,
      afterInsert: afterInsert,
      afterUpdate: afterUpdate,
      afterRemove: afterRemove,
    );
