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

  List<VdomNode> buildNodes(content) => _buildNodes(new NodeRefs(), content);

  List<VdomNode> _buildNodes(NodeRefs nodeRefs, dynamic content,
      {List<VdomNode> nodes, ElementProxy proxy}) {
    if (content == null) {
      return nodes;
    }
    nodes ??= [];
    for (var item in unfold(content)) {
      if (item == null) {
        continue;
      } else if (item is Element) {
        final velem = new VdomElement()..tag = item.tag;
        nodes.add(velem);
        velem.children = _buildNodes(nodeRefs, item.content, proxy: velem);
        if (velem.symbol != null || velem.events != null) {
          nodeRefs.add(velem);
        }
        velem.nodeRefs = nodeRefs;
      } else if (item is Component) {
        final forked = _fork(item);
        forked._buildNodes(new NodeRefs(), item.build(forked), nodes: nodes);
      } else if (item is BuildFn) {
        _buildNodes(nodeRefs, item(this), nodes: nodes);
      } else if (item is Setter) {
        if (proxy != null) {
          item.apply(proxy);
        }
      } else if (item is Map) {
        if (proxy != null) {
          for (String key in item.keys) {
            proxy.setAttribute(key, item[key]);
          }
        }
      } else if (item is Symbol) {
        proxy?.setSymbol(item);
      } else {
        nodes.add(new VdomText(item.toString()));
      }
    }

    return nodes;
  }
}
