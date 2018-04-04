import '../domino.dart';

import '_unfold.dart';
import '_vdom.dart';

class BuildContextImpl implements BuildContext {
  @override
  final View view;

  final BuildContextImpl _parent;
  final Component _component;

  BuildContextImpl._(this.view, this._parent, this._component);
  BuildContextImpl(this.view)
      : _parent = null,
        _component = null;

  BuildContextImpl _fork(Component component) =>
      new BuildContextImpl._(view, this, component);

  @override
  Component get component => _component;

  @override
  Iterable<Component> get components sync* {
    BuildContextImpl ctx = this;
    while (ctx != null) {
      if (ctx._component != null) {
        yield ctx._component;
      }
      ctx = ctx._parent;
    }
  }

  List<VdomNode> buildNodes(content, {PathState pathState}) =>
      _buildNodes(pathState, new _Path._init('@root'), new NodeRefs(), content);

  List<VdomNode> _buildNodes(
      PathState pathState, _Path path, NodeRefs nodeRefs, dynamic content,
      {List<VdomNode> nodes}) {
    if (content == null) {
      return nodes;
    }
    nodes ??= [];
    for (var item in unfold(content)) {
      if (item == null) {
        continue;
      } else if (item is Element) {
        final velem = new VdomElement()..tag = item.tag;
        final contentChildren = _contentChildren(velem, item.content);
        if (velem.symbol != null || velem.events != null) {
          nodeRefs.add(velem);
        }
        velem.nodeRefs = nodeRefs;
        nodes.add(velem);
        velem.children = _buildNodes(
            pathState,
            path.append(velem.symbol ?? nodes.length, item.tag),
            nodeRefs,
            contentChildren);
      } else if (item is Component) {
        final newPath = path.append(nodes.length, item.runtimeType);
        var component = item;
        if (item is StatefulComponent) {
          final stored = pathState.get(newPath);
          component = item.restoreState(stored) ?? item;
        }
        final forked = _fork(component);
        forked._buildNodes(
            pathState, newPath, new NodeRefs(), component.build(forked),
            nodes: nodes);
        if (component is StatefulComponent) {
          pathState.add(newPath, component);
        }
      } else if (item is BuildFn) {
        _buildNodes(pathState, path, nodeRefs, item(this), nodes: nodes);
      } else if (item is NoContextBuildFn) {
        _buildNodes(pathState, path, nodeRefs, item(), nodes: nodes);
      } else {
        nodes.add(new VdomText(item.toString()));
      }
    }

    return nodes;
  }

  List _contentChildren(ElementProxy proxy, content) {
    List result;
    for (var item in unfold(content)) {
      if (item == null) continue;
      if (item is Setter) {
        item.apply(proxy);
        continue;
      } else if (item is Map) {
        for (String key in item.keys) {
          proxy.setAttribute(key, item[key]);
        }
        continue;
      } else if (item is Symbol) {
        proxy.setSymbol(item);
        continue;
      }
      result ??= [];
      result.add(item);
    }
    return result;
  }
}

class _Path {
  final _Path previous;
  final dynamic index;
  final dynamic value;

  _Path._(this.previous, this.index, this.value);
  _Path._init(this.value)
      : index = 0,
        previous = null;

  _Path append(dynamic index, value) => new _Path._(this, index, value);

  bool matches(_Path other) {
    if (other == null) return false;
    if (this.index != other.index) return false;
    if (this.value != other.value) return false;
    if (this.previous == null && other.previous == null) return true;
    if (this.previous == null || other.previous == null) return false;
    return this.previous.matches(other.previous);
  }
}

class _PathComponent {
  final _Path path;
  final StatefulComponent component;
  _PathComponent(this.path, this.component);
}

class PathState {
  final List<_PathComponent> _oldState;
  final List<_PathComponent> _newState = [];

  PathState([List<_PathComponent> oldState]) : _oldState = oldState ?? [];

  void add(_Path path, StatefulComponent component) {
    _newState.add(new _PathComponent(path, component));
  }

  StatefulComponent get(_Path path) {
    return _oldState
        .firstWhere((pc) => pc.path.matches(path), orElse: () => null)
        ?.component;
  }

  PathState fork() => new PathState(_newState);
}
