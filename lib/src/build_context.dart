import '../domino.dart';

import 'unfold.dart';
import 'vdom.dart';

class BuildContextImpl implements BuildContext {
  @override
  final View view;

  final BuildContextImpl _parent;
  final Component _component;
  KeyedRefs _keyedRefs;

  BuildContextImpl._(this.view, this._parent, this._component);
  BuildContextImpl.initView(this.view)
      : _parent = null,
        _component = null;

  BuildContextImpl fork({Component component}) =>
      new BuildContextImpl._(view, this, component);

  BuildContextImpl get root => _parent == null ? this : _parent.root;

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

  List<VdomNode> buildNodes(content) => _buildNodes(content);

  List<VdomNode> _buildNodes(dynamic content,
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
        velem.children = _buildNodes(item.content, proxy: velem);
        if (velem.key != null || velem.events != null) {
          _keyedRefs ??= new KeyedRefs();
          _keyedRefs.add(velem);
        }
        velem.keyedRefs = _keyedRefs;
      } else if (item is Component) {
        final forked = fork(component: item);
        forked._buildNodes(item.build(forked), nodes: nodes);
      } else if (item is BuildFn) {
        _buildNodes(item(this), nodes: nodes);
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
      } else {
        nodes.add(new VdomText(item.toString()));
      }
    }

    return nodes;
  }
}
