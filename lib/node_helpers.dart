import 'domino.dart';

/// Creates a <div> Element.
Element div({
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
    _elem('div', attrs, styles, classes, content, events, key, afterInsert,
        afterUpdate, afterRemove);

Element _elem(
  String tag,
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

Element button({
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
    _elem('button', attrs, styles, classes, content, events, key, afterInsert,
        afterUpdate, afterRemove)
      ..onClick(onClick);

Element br() => new Element('br');
