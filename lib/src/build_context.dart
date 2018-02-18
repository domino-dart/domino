import '../domino.dart';
import '../experimental.dart';

class AncestorBuildContext implements BuildContext {
  final View _view;
  final List _ancestors = [];
  final List _path = [];
  final Map<String, StatefulComponent> _oldStates;
  final Map<String, StatefulComponent> _newStates = {};

  AncestorBuildContext(this._view, this._oldStates);

  @override
  View get view => _view;

  @override
  Iterable get ancestors => _ancestors.reversed.skip(1);

  List<Node> buildNodes(dynamic content) => _buildNodes(content);

  Map<String, StatefulComponent> getStates() => _newStates;

  List<Node> _buildNodes(dynamic item, {List<Node> nodes}) {
    if (item == null) {
      return nodes;
    }
    nodes ??= [];
    if (item is String) {
      nodes.add(new Text(item));
    } else if (item is Element) {
      _ancestors.add(item);
      if (item.key != null) {
        _path.add('@key:${item.key}');
      } else {
        _path.add(item.tag);
      }
      nodes.add(new _ElementProxy(item, _buildNodes(item.content)));
      _path.removeLast();
      _ancestors.removeLast();
    } else if (item is Node) {
      nodes.add(item);
    } else if (item is Iterable) {
      int index = 0;
      for (var child in item) {
        _path.add(index);
        _buildNodes(child, nodes: nodes);
        _path.removeLast();
        index++;
      }
    } else if (item is BuildFn) {
      _path.add('@fn');
      _buildNodes(item(this), nodes: nodes);
      _path.removeLast();
    } else if (item is Component) {
      _ancestors.add(item);
      _path.add(item.runtimeType);
      if (item is StatefulComponent) {
        final path = _path.join('/');
        final oldState = _oldStates[path];
        item.setState(oldState?.getState());
        _newStates[path] = item;
      }
      _buildNodes(item.build(this), nodes: nodes);
      _path.removeLast();
      _ancestors.removeLast();
    } else {
      nodes.add(new Text(item.toString()));
    }
    return nodes;
  }
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
