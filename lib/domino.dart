import 'dart:async';

/// The context of the current build.
abstract class BuildContext {
  /// List of ancestor [Element]s or [Component]s. Ordered from the bottom
  /// (direct parent) to the top (root [Component] or [Element]).
  Iterable get ancestors;
}

/// Builds a single or List-embedded structure of Nodes and/or Components.
typedef dynamic BuildFn(BuildContext context);

/// A state-holder component that builds a single or List-embedded structure of
/// Nodes and/or Components.
abstract class Component {
  /// Builds a single or List-embedded structure of Nodes and/or Components.
  dynamic build(BuildContext context);
}

/// Provides lifecycle handling for a hierarchy of components.
abstract class View {
  /// Schedule an update of the [View].
  Future invalidate();

  /// Dispose the [View] and free resources.
  Future dispose();
}

/// DOM Event wrapper.
abstract class Event {
  dynamic get domElement;
  dynamic get domEvent;

  bool get defaultPrevented;
  void preventDefault();
  void stopImmediatePropagation();
  void stopPropagation();
}

/// Handles events.
typedef void EventHandler(Event event);

/// Node in the DOM.
abstract class Node extends Object with _AfterCallbacks, _OnEvents {
  dynamic key;
}

/// Element in the DOM.
class Element extends Node
    with _ElementContent, _ElementClasses, _ElementStyles, _ElementAttributes {
  final String tag;

  Element(
    this.tag, {
    List<String> classes,
    Map<String, String> styles,
    Map<String, String> attrs,
    /* List, Component, Node, BuildFn */ dynamic content,
    Map<String, EventHandler> events,
    dynamic key,
    AfterCallback afterInsert,
    AfterCallback afterUpdate,
    AfterCallback afterRemove,
  }) {
    this.key = key;
    this.afterInsert(afterInsert);
    this.afterUpdate(afterUpdate);
    this.afterRemove(afterRemove);
    this.onEvents(events);
    this.content = content;
    this.classes = classes;
    this.styles = styles;
    this.attrs = attrs;
  }
}

/// Text node in the DOM.
class Text extends Node {
  String text;

  Text(
    this.text, {
    dynamic key,
    AfterCallback afterInsert,
    AfterCallback afterUpdate,
    AfterCallback afterRemove,
  }) {
    this.key = key;
    this.afterInsert(afterInsert);
    this.afterUpdate(afterUpdate);
    this.afterRemove(afterRemove);
  }
}

/// Handles DOM callbacks after changes were applied.
typedef void AfterCallback(node);

abstract class _AfterCallbacks {
  List<AfterCallback> _afterInserts;
  List<AfterCallback> _afterUpdates;
  List<AfterCallback> _afterRemoves;

  bool get hasAfterInserts => _afterInserts != null;
  bool get hasAfterUpdates => _afterUpdates != null;
  bool get hasAfterRemoves => _afterRemoves != null;

  Iterable<AfterCallback> get afterInserts => _afterInserts;
  Iterable<AfterCallback> get afterUpdates => _afterUpdates;
  Iterable<AfterCallback> get afterRemoves => _afterRemoves;

  void afterInsert(AfterCallback callback) {
    if (callback == null) return;
    _afterInserts ??= [];
    _afterInserts.add(callback);
  }

  void afterUpdate(AfterCallback callback) {
    if (callback == null) return;
    _afterUpdates ??= [];
    _afterUpdates.add(callback);
  }

  void afterRemove(AfterCallback callback) {
    if (callback == null) return;
    _afterRemoves ??= [];
    _afterRemoves.add(callback);
  }
}

abstract class _OnEvents {
  List<_TypeAndHandler> _events;

  bool get hasEventHandlers => _events != null;

  void on(String type, EventHandler handler) {
    if (type == null) return;
    _events ??= [];
    _events.add(new _TypeAndHandler(type, handler));
  }

  void onClick(EventHandler handler) => on('click', handler);

  void onEvents(Map<String, EventHandler> events) {
    if (events == null) return;
    events.forEach(on);
  }

  Iterable<R> mapEventHandlers<R>(R fn(String type, EventHandler handler)) {
    return _events.map((e) => fn(e.type, e.handler));
  }
}

class _TypeAndHandler {
  final String type;
  final EventHandler handler;
  _TypeAndHandler(this.type, this.handler);
}

class _ElementContent {
  /* List, Component, Node, BuildFn, ... */ dynamic content;

  bool get hasContent => content != null;
}

class _ElementClasses {
  List<String> _classes;

  bool get hasClasses => _classes != null;
  Iterable<String> get classes => _classes;
  void set classes(List<String> values) {
    _classes = values?.where((s) => s != null)?.toList();
  }

  void addClass(String value) {
    if (value == null) return;
    _classes ??= [];
    _classes.add(value);
  }
}

class _ElementStyles {
  Map<String, String> styles;

  void style(String name, String value) {
    styles ??= {};
    styles[name] = value;
  }
}

class _ElementAttributes {
  Map<String, String> attrs;

  void attr(String name, String value) {
    attrs ??= {};
    attrs[name] = value;
  }
}
