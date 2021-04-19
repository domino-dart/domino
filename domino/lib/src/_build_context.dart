import '../domino.dart';

import '_unfold.dart';
import '_vdom.dart';

/// Builds a single or List-embedded structure of Nodes and/or Components.
typedef _BuildFn = Function(BuildContext context);

/// Builds a single or List-embedded structure of Nodes and/or Components
/// without the need of [BuildContext].
typedef _NoContextBuildFn = Function();

class BuildContextImpl implements BuildContext {
  @override
  final View view;

  final BuildContextImpl? _parent;
  final Component? _component;

  BuildContextImpl._(this.view, this._parent, this._component);
  BuildContextImpl(this.view)
      : _parent = null,
        _component = null;

  BuildContextImpl _fork(Component component) =>
      BuildContextImpl._(view, this, component);

  @override
  Component? get component => _component;

  @override
  Iterable<Component> get components sync* {
    BuildContextImpl? ctx = this;
    while (ctx != null) {
      if (ctx._component != null) {
        yield ctx._component!;
      }
      ctx = ctx._parent;
    }
  }

  List<VdomNode>? buildNodes(dynamic content) =>
      _buildNodes(NodeRefs(), content);

  List<VdomNode>? _buildNodes(NodeRefs nodeRefs, dynamic content,
      {List<VdomNode>? nodes}) {
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
        velem.children = _buildNodes(nodeRefs, contentChildren);
      } else if (item is Component) {
        final component = item;
        final forked = _fork(component);
        forked._buildNodes(NodeRefs(), component.build(forked), nodes: nodes);
      } else if (item is _BuildFn) {
        _buildNodes(nodeRefs, item(this), nodes: nodes);
      } else if (item is _NoContextBuildFn) {
        _buildNodes(nodeRefs, item(), nodes: nodes);
      } else {
        nodes.add(VdomText(item.toString()));
      }
    }

    return nodes;
  }

  List? _contentChildren(ElementProxy proxy, content) {
    List? result;
    for (var item in unfold(content)) {
      if (item == null) continue;
      if (item is Setter) {
        item.apply(proxy);
        continue;
      } else if (item is Map<String, String>) {
        for (final key in item.keys) {
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
