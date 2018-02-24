import 'dart:async';
import 'dart:html' as html;

import 'package:async_tracker/async_tracker.dart';

import 'domino.dart';
import 'src/_build_context.dart';
import 'src/_vdom.dart';

export 'domino.dart';

/// Register [content] (e.g. single [Component] or list of [Component] and
/// [Node]s) to the [container] Element and start a [View].
View registerHtmlView(html.Element container, dynamic content) {
  return new _View(container, content);
}

class _View implements View {
  final html.Element _container;
  final _content;

  AsyncTracker _tracker;

  Future _invalidate;
  bool _isDisposed = false;

  _View(this._container, this._content) {
    _tracker = new AsyncTracker()..addListener(invalidate);
    invalidate();
  }

  @override
  R track<R>(R action()) => _tracker.run(action);

  @override
  R escape<R>(R action()) => _tracker.parentZone.run(action);

  @override
  Future invalidate() {
    if (_invalidate != null) {
      return _invalidate;
    }
    _invalidate = new Future.microtask(() {
      try {
        final nodes = new BuildContextImpl(this).buildNodes(_content) ??
            const <VdomNode>[];
        final updater = new _ViewUpdater(this);
        updater._update(_container, _isDisposed ? const [] : nodes);
        updater._runCallbacks();
      } finally {
        _invalidate = null;
      }
    });
    return _invalidate;
  }

  @override
  Future dispose() async {
    _isDisposed = true;
    return invalidate();
  }
}

class _EventSubscription {
  final String type;
  final Function listener;
  final EventHandler handler;

  _EventSubscription(this.type, this.listener, this.handler);
}

typedef void _ContextCallbackFn();

class _ViewUpdater {
  final _View _view;
  final List<_ContextCallbackFn> _onInsertQueue = [];
  final List<_ContextCallbackFn> _onUpdateQueue = [];
  final List<_ContextCallbackFn> _onRemoveQueue = [];

  _ViewUpdater(this._view);

  void _runCallbacks() {
    _onInsertQueue.forEach((fn) => fn());
    _onUpdateQueue.forEach((fn) => fn());
    _onRemoveQueue.forEach((fn) => fn());
  }

  void _update(html.Element container, List<VdomNode> nodes) {
    nodes ??= const <VdomNode>[];
    for (int i = 0; i < nodes.length; i++) {
      final vnode = nodes[i];
      html.Node domNode;
      _VdomSource source;
      for (int j = i; j < container.nodes.length; j++) {
        final dn = container.nodes[j];
        final dnsrc = _getSource(dn);
        final dnSymbol = dnsrc.symbol;
        if (vnode.symbol != null && vnode.symbol == dnSymbol) {
          domNode = dn;
          source = dnsrc;
        } else if (dnSymbol == null && _mayUpdate(dn, dnsrc, vnode)) {
          domNode = dn;
          source = dnsrc;
        }
        if (domNode != null) {
          if (j != i) {
            dn.remove();
            container.nodes.insert(i, dn);
          }
          break;
        }
      }
      if (domNode != null) {
        _updateNode(domNode, source, vnode);
        if (vnode.hasAfterUpdates) {
          final c = new _Change(ChangePhase.update, domNode);
          final list =
              vnode.changes[ChangePhase.update].map((fn) => () => fn(c));
          _onUpdateQueue.addAll(list);
        }
      } else {
        final dn = _createDom(vnode);
        final dnsrc = _getSource(dn);
        _updateNode(dn, dnsrc, vnode);
        if (i < container.nodes.length) {
          container.nodes.insert(i, dn);
        } else {
          container.append(dn);
        }
        if (vnode.hasAfterInserts) {
          final c = new _Change(ChangePhase.insert, dn);
          final list =
              vnode.changes[ChangePhase.insert].map((fn) => () => fn(c));
          _onInsertQueue.addAll(list);
        }
        if (vnode.hasAfterRemoves) {
          final p = new _Change(ChangePhase.insert, dn);
          dnsrc.onRemove = vnode.changes[ChangePhase.remove]
              .map((fn) => () => fn(p))
              .toList();
        }
      }
    }

    // delete extra DOM nodes
    while (nodes.length < container.nodes.length) {
      _removeAll(container.nodes.removeLast());
    }
  }

  bool _mayUpdate(html.Node dn, _VdomSource source, VdomNode vnode) {
    if (vnode is VdomElement &&
        dn is html.Element &&
        vnode.tag.toLowerCase() == dn.tagName.toLowerCase()) {
      // We are not able to iterate the style keys to remove them properly.
      if (dn.style.length > 0 && vnode.styles != null) {
        if (vnode.styles.length != dn.style.length) {
          return false;
        }
        for (String key in vnode.styles.keys) {
          if (dn.style.getPropertyValue(key) == null) {
            return false;
          }
        }
      }
      return source.hasNoCallbacks;
    } else if (vnode is VdomText && dn is html.Text) {
      return source.hasNoCallbacks;
    } else {
      return false;
    }
  }

  html.Node _createDom(VdomNode vnode) {
    if (vnode is VdomText) {
      return new html.Text(vnode.value);
    } else if (vnode is VdomElement) {
      return new html.Element.tag(vnode.tag);
    } else {
      throw new Exception('Unknown vnode: $vnode');
    }
  }

  void _updateNode(html.Node dn, _VdomSource source, VdomNode vnode) {
    if (dn is html.Text && vnode is VdomText) {
      _updateText(dn, vnode);
    } else if (dn is html.Element && vnode is VdomElement) {
      _updateElement(dn, source, vnode);
    }
    source.symbol = vnode.symbol;
  }

  void _updateText(html.Text dn, VdomText vnode) {
    if (!identical(dn.text, vnode.value)) {
      dn.text = vnode.value;
    }
  }

  void _updateElement(html.Element dn, _VdomSource source, VdomElement vnode) {
    final boundKeyedRefs = vnode.nodeRefs?.bind(vnode.symbol, dn);

    final Set<String> attrsToRemove = source.attributes?.keys?.toSet();
    if (vnode.hasClasses) {
      attrsToRemove?.remove('class');
    }
    if (vnode.styles != null) {
      attrsToRemove?.remove('style');
    }

    if (vnode.attributes != null) {
      for (String key in vnode.attributes.keys) {
        attrsToRemove?.remove(key);
        final String value = vnode.attributes[key];
        if (dn.getAttribute(key) != value) {
          if (value == null) {
            dn.attributes.remove(key);
          } else {
            dn.setAttribute(key, value);
          }
        }
      }
    }
    attrsToRemove?.forEach(dn.attributes.remove);
    source.attributes = vnode.attributes;

    if (source.classes != null) {
      for (String s in source.classes) {
        if (vnode.classes == null || !vnode.classes.contains(s)) {
          dn.classes.remove(s);
        }
      }
    }
    if (vnode.classes != null) {
      for (String s in vnode.classes) {
        if (source.classes == null || !source.classes.contains(s)) {
          dn.classes.add(s);
        }
      }
    }
    source.classes = vnode.classes;

    if (source.styles != null) {
      for (String key in source.styles.keys) {
        if (vnode.styles == null || !vnode.styles.containsKey(key)) {
          dn.style.removeProperty(key);
        }
      }
    }
    if (vnode.styles != null) {
      for (String key in vnode.styles.keys) {
        final String value = vnode.styles[key];
        if (dn.style.getPropertyValue(key) != value) {
          dn.style.setProperty(key, value);
        }
      }
    }
    source.styles = vnode.styles;

    final List<_EventSubscription> oldEvents = source.events;
    List<_EventSubscription> newEvents;
    if (vnode.hasEventHandlers) {
      newEvents = vnode.mapEventHandlers((type, handler) {
        if (handler == null) return null;
        if (oldEvents != null) {
          final old = oldEvents.firstWhere(
              (es) => es.type == type && es.handler == handler,
              orElse: () => null);
          if (old != null) {
            return old;
          }
        }
        final listener = (e) {
          return _view._tracker
              .run(() => handler(new _DomEvent(type, dn, e, boundKeyedRefs)));
        };
        return new _EventSubscription(type, listener, handler);
      }).toList();
    }
    oldEvents
        ?.where((es) => newEvents == null || !newEvents.contains(es))
        ?.forEach((es) => dn.removeEventListener(es.type, es.listener));
    newEvents
        ?.where((es) => oldEvents == null || !oldEvents.contains(es))
        ?.forEach((es) => dn.addEventListener(es.type, es.listener));

    if (newEvents != null || oldEvents != null) {
      source.events = newEvents;
    }

    _update(dn, vnode.children);
  }

  void _removeAll(html.Node node) {
    final source = _getSource(node);
    final List<_EventSubscription> oldEvents = source.events;
    if (oldEvents != null) {
      for (var es in oldEvents) {
        node.removeEventListener(es.type, es.listener);
      }
    }

    final List<_ContextCallbackFn> onRemoveCallbacks = source.onRemove;
    if (onRemoveCallbacks != null) {
      _onRemoveQueue.addAll(onRemoveCallbacks);
    }

    if (node.hasChildNodes()) {
      for (var child in node.nodes) {
        _removeAll(child);
      }
    }
  }
}

class _DomEvent implements Event {
  final String _type;
  final html.Element _element;
  final html.Event _event;
  final Map<Symbol, html.Node> _nodesBySymbol;
  _DomEvent(this._type, this._element, this._event, this._nodesBySymbol);

  @override
  String get type => _type;

  @override
  html.Element get element => _element;

  @override
  dynamic get event => _event;

  html.Node getNodeBySymbol(Symbol symbol) {
    if (_nodesBySymbol == null) return null;
    return _nodesBySymbol[symbol];
  }

  @override
  bool get defaultPrevented => _event.defaultPrevented;

  @override
  void preventDefault() => _event.preventDefault();

  @override
  void stopImmediatePropagation() => _event.stopImmediatePropagation();

  @override
  void stopPropagation() => _event.stopPropagation();
}

/// Creates a detachable sub-[View].
class SubView implements Component {
  final String _tag;
  final _content;
  final Invalidation _invalidation;

  html.Element _container;
  View _view;

  SubView({
    String tag,
    content,
    Invalidation invalidation,
  })
      : _tag = tag ?? 'div',
        _content = content,
        _invalidation = invalidation;

  @override
  build(BuildContext context) {
    return new Element(_tag, [
      afterInsert(_afterInsert),
      afterUpdate(_afterUpdate),
      afterRemove(_afterRemove),
    ]);
  }

  void _afterInsert(Change context) {
    _container = context.node;
    _view = registerHtmlView(_container, _content);
  }

  void _afterUpdate(Change context) {
    if (_invalidation == Invalidation.down) {
      _view.invalidate();
    }
  }

  void _afterRemove(Change context) {
    _view.dispose();
  }
}

/// The direction of the invalidation in the context of a parent and child [View].
enum Invalidation {
  /// The parent and the child live separate lifecycles, invalidation in one
  /// doesn't affect the other.
  none,

  /// Invalidation in the parent triggers invalidation in teh child, but not the
  /// other way around
  down,

  // TODO: add up,

  // TODO: add both,
}

class _Change extends Change {
  @override
  final ChangePhase phase;

  @override
  final node;

  _Change(this.phase, this.node);
}

class _VdomSource {
  Symbol symbol;
  Map<String, String> attributes;
  List<String> classes;
  Map<String, String> styles;

  List<_EventSubscription> events;
  List<_ContextCallbackFn> onRemove;

  bool get hasNoCallbacks =>
      (events == null || events.isEmpty) &&
      (onRemove == null || onRemove.isEmpty);
}

final Expando<_VdomSource> _vdomSourceExpando = new Expando();

_VdomSource _getSource(html.Node node) {
  var src = _vdomSourceExpando[node];
  if (src == null) {
    src = new _VdomSource();
    _vdomSourceExpando[node] = src;
  }
  return src;
}
