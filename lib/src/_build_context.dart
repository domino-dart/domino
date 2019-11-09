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
      BuildContextImpl._(view, this, component);

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
      _buildNodes(pathState, _Path._init('@root'), NodeRefs(), content);

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
        final velem = VdomElement()..tag = item.tag;
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
        final p = path.append(nodes.length, item.runtimeType);
        var component = item;
        // ignore: deprecated_member_use_from_same_package
        if (item is StatefulComponent) {
          final stored = pathState.get(p);
          component = item.restoreState(stored) ?? item;
        }
        final forked = _fork(component);
        forked._buildNodes(pathState, p, NodeRefs(), component.build(forked),
            nodes: nodes);
        // ignore: deprecated_member_use_from_same_package
        if (component is StatefulComponent) {
          pathState.add(p, component);
        }
      // ignore: deprecated_member_use_from_same_package
      } else if (item is BuildFn) {
        _buildNodes(pathState, path, nodeRefs, item(this), nodes: nodes);
      // ignore: deprecated_member_use_from_same_package
      } else if (item is NoContextBuildFn) {
        _buildNodes(pathState, path, nodeRefs, item(), nodes: nodes);
      } else {
        nodes.add(VdomText(item.toString()));
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
      } else if (item is Map<String, String>) {
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

  _Path append(dynamic index, value) => _Path._(this, index, value);

  bool matches(_Path other) {
    if (other == null) return false;
    if (index != other.index) return false;
    if (value != other.value) return false;
    if (previous == null && other.previous == null) return true;
    if (previous == null || other.previous == null) return false;
    return previous.matches(other.previous);
  }
}

class _PathComponent {
  final _Path path;
  // ignore: deprecated_member_use_from_same_package
  final StatefulComponent component;
  _PathComponent(this.path, this.component);
}

class PathState {
  final List<_PathComponent> _oldState;
  final _state = <_PathComponent>[];

  PathState([List<_PathComponent> oldState])
      : _oldState = oldState ?? <_PathComponent>[];

  // ignore: deprecated_member_use_from_same_package
  void add(_Path path, StatefulComponent component) {
    _state.add(_PathComponent(path, component));
  }

  // ignore: deprecated_member_use_from_same_package
  StatefulComponent get(_Path path) {
    return _oldState
        .firstWhere((pc) => pc.path.matches(path), orElse: () => null)
        ?.component;
  }

  PathState fork() => PathState(_state);
}
