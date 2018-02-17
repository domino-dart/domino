import 'package:domino/domino.dart';

import '../domino.dart';

class AncestorBuildContext implements BuildContext {
  final List _ancestors = [];

  @override
  Iterable get ancestors => _ancestors.reversed.skip(1);

  void _pushAncestor(item) {
    _ancestors.add(item);
  }

  _popAncestor() {
    _ancestors.removeLast();
  }
}

List<Node> flattenWithContext(AncestorBuildContext context, dynamic item,
    {List<Node> nodes}) {
  if (item == null) {
    return nodes;
  }
  nodes ??= [];
  if (item is String) {
    nodes.add(new Text(item));
  } else if (item is Element) {
    context._pushAncestor(item);
    nodes.add(
        new _ElementProxy(item, flattenWithContext(context, item.content)));
    context._popAncestor();
  } else if (item is Node) {
    nodes.add(item);
  } else if (item is Iterable) {
    for (var child in item) {
      flattenWithContext(context, child, nodes: nodes);
    }
  } else if (item is BuildFn) {
    flattenWithContext(context, item(context), nodes: nodes);
  } else if (item is Component) {
    context._pushAncestor(item);
    flattenWithContext(context, item.build(context), nodes: nodes);
    context._popAncestor();
  } else {
    nodes.add(new Text(item.toString()));
  }
  return nodes;
}

class _ElementProxy implements Element {
  final Element _delegate;
  final List<Node> _nodes;

  _ElementProxy(this._delegate, this._nodes);

  @override
  String get tag => _delegate.tag;

  @override
  Map<String, String> get attrs => _delegate.attrs;

  @override
  Iterable get content => _nodes;

  @override
  Iterable<String> get classes => _delegate.classes;

  @override
  get key => _delegate.key;

  @override
  Map<String, String> get styles => _delegate.styles;

  @override
  Iterable<AfterCallback> get afterInserts => _delegate.afterInserts;

  @override
  Iterable<AfterCallback> get afterUpdates => _delegate.afterUpdates;

  @override
  Iterable<AfterCallback> get afterRemoves => _delegate.afterRemoves;

  @override
  bool get hasAfterInserts => _delegate.hasAfterInserts;

  @override
  bool get hasAfterUpdates => _delegate.hasAfterUpdates;

  @override
  bool get hasAfterRemoves => _delegate.hasAfterRemoves;

  @override
  bool get hasClasses => _delegate.hasClasses;

  @override
  bool get hasContent => _delegate.hasContent;

  @override
  bool get hasEventHandlers => _delegate.hasEventHandlers;

  @override
  Iterable<R> mapEventHandlers<R>(Function fn) =>
      _delegate.mapEventHandlers(fn);

  @override
  void addClass(String value) {
    _notSupported();
  }

  @override
  void afterInsert(AfterCallback callback) {
    _notSupported();
  }

  @override
  void afterRemove(AfterCallback callback) {
    _notSupported();
  }

  @override
  void afterUpdate(AfterCallback callback) {
    _notSupported();
  }

  @override
  void attr(String name, String value) {
    _notSupported();
  }

  @override
  void set attrs(Map<String, String> _attrs) {
    _notSupported();
  }

  @override
  void set classes(value) {
    _notSupported();
  }

  @override
  set content(_content) {
    _notSupported();
  }

  @override
  void set key(_key) {
    _notSupported();
  }

  @override
  void on(String type, EventHandler handler) {
    _notSupported();
  }

  @override
  void onClick(EventHandler handler) {
    _notSupported();
  }

  @override
  void onEvents(Map<String, EventHandler> events) {
    _notSupported();
  }

  @override
  void style(String name, String value) {
    _notSupported();
  }

  @override
  void set styles(Map<String, String> _styles) {
    _notSupported();
  }

  void _notSupported() {
    throw new StateError('Not supported.');
  }
}
