import 'dart:async';

import 'src/_setters.dart';

/// The context of the current build.
abstract class BuildContext {
  /// The current [View] which triggered the build.
  View get view;

  /// The currently active component.
  Component get component;

  /// List of [Component]s, ordered from the currently active to the top-level ones.
  Iterable<Component> get components;
}

/// Builds a single or List-embedded structure of Nodes and/or Components.
@Deprecated('typedef will be private')
typedef BuildFn(BuildContext context);

/// Builds a single or List-embedded structure of Nodes and/or Components
/// without the need of [BuildContext].
@Deprecated('typedef will be private')
typedef NoContextBuildFn();

/// Builds a single or List-embedded structure of Nodes and/or Components.
abstract class Component {
  /// Builds a single or List-embedded structure of Nodes and/or Components.
  build(BuildContext context);
}

/// A component that can restore its state from a previous build.
@Deprecated('StatefulComponent is obsolete, keep references instead.')
abstract class StatefulComponent implements Component {
  /// Restores the state from [previous] component, and returns the instance
  /// that will be used for the build.
  ///
  /// It is legit to return the previous instance, doing a quick state hand-off.
  /// (And it is the default for components extending this class.)
  Component restoreState(Component previous) => previous ?? this;
}

/// Provides lifecycle handling for a hierarchy of components.
/// A [View] re-builds the UI after `invalidate()` is called (or automatically
/// when [EventHandler]s are registered).
abstract class View {
  /// Schedule an update of the [View].
  Future invalidate();

  /// Runs [action] in the [View]'s tracker zone.
  ///
  /// This zone tracks the execution of [action] and its async callbacks,
  /// triggering the invalidation and (re-)building of the [View] after each run.
  ///
  /// [EventHandler]s registered in the [View] during the build phase will be
  /// using this automatically.
  R track<R>(R action());

  /// Escapes the [View]'s tracker zone (e.g. from inside an [EventHandler]),
  /// no longer triggering the invalidation of the [View] after its run finishes.
  R escape<R>(R action());

  /// Dispose the [View] and free resources.
  Future dispose();
}

/// DOM Event wrapper.
abstract class EventContext {
  /// The current [View] which triggered the event.
  View get view;

  /// The event type (e.g. 'click').
  String get type;

  /// The DOM Element where the event handler was registered.
  get element;

  /// The native event.
  get event;

  /// Returns a DOM Node identified with a Symbol.
  N getNode<N>(Symbol symbol);

  bool get defaultPrevented;
  void preventDefault();
  void stopImmediatePropagation();
  void stopPropagation();
}

/// Handles events.
typedef void EventHandler(EventContext ctx);

/// A virtual dom element that has a 1:1 mapping to an element in the real DOM.
class Element {
  final String tag;
  final dynamic content;

  Element(this.tag, [this.content]);

  /// Creates a instance with [items] appended as content.
  Element append(items) => Element(tag, [content, items]);
}

/// Enables collecting of virtual dom properties that will be applied on real DOM.
abstract class ElementProxy {
  void setSymbol(Symbol symbol);
  void addClass(String className);
  void setAttribute(String name, String value);
  void setStyle(String name, String value);
  void setInnerHtml(String html);
  void addEventHandler(String type, Function handler, bool tracked);
  void addChangeHandler(ChangePhase phase, ChangeHandler handler);
}

/// Sets properties of a DOM Element.
abstract class Setter {
  /// Sets the properties of a DOM element.
  void apply(ElementProxy proxy);
}

enum ChangePhase { insert, update, remove }

abstract class Change {
  ChangePhase get phase;
  get node;

  bool get isInsert => phase == ChangePhase.insert;
  bool get isUpdate => phase == ChangePhase.update;
  bool get isRemove => phase == ChangePhase.remove;
}

typedef void ChangeHandler(Change lifecycle);

/// Adds a style to an [Element] with [name] and [value]
///
/// Example:
///     div(style('color', 'blue'))
Setter style(String name, String value) => StyleSetter(name, value);

/// Adds an attribute to an [Element] with [name] and [value]
///
/// Example:
///     div(attr('id', 'main'))
Setter attr(String name, String value) => AttrSetter(name, value);

/// Adds an `id` attribute to an [Element] with [id] as value.
///
/// Example:
///     div(id('main'))
Setter id(String id) => attr('id', id);

/// Adds classes to an [Element]
///
/// Example:
///     div(clazz('main'))
Setter clazz(class1, [class2, class3, class4, class5]) =>
    ClassAdder(class1, class2, class3, class4, class5);

/// Adds an [handler] to an [Element] for event [event].
///
/// Event handlers by default trigger [View.invalidate] on their callback and on
/// every asynchronous method that is associated with their run (e.g. `Future`,
/// `Stream` or `Timer`). To turn this off, set [tracked] to `false`.
///
/// Example:
///     div(on('click', () => print('Clicked!')))
Setter on(String event, Function handler, {bool tracked}) {
  return EventSetter(event, handler, tracked: tracked);
}

Setter afterInsert(ChangeHandler handler) {
  if (handler == null) return null;
  return LifecycleSetter(ChangePhase.insert, handler);
}

Setter afterUpdate(ChangeHandler handler) {
  if (handler == null) return null;
  return LifecycleSetter(ChangePhase.update, handler);
}

Setter afterRemove(ChangeHandler handler) {
  if (handler == null) return null;
  return LifecycleSetter(ChangePhase.remove, handler);
}

Setter innerHtml(String html) {
  if (html == null) return null;
  return InnerHtmlSetter(html);
}
