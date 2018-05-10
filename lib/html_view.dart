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
  PathState _pathState = new PathState();

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
    _invalidate ??= new Future.delayed(Duration.zero, () {
      try {
        _pathState = _pathState.fork();
        final nodes = new BuildContextImpl(this)
                .buildNodes(_content, pathState: _pathState) ??
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
  final Function handler;
  final bool tracked;

  _EventSubscription(this.type, this.listener, this.handler, this.tracked);
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
    if (vnode?.type == null) return false;
    switch (vnode.type) {
      case VdomNodeType.element:
        if (vnode is VdomElement &&
            dn is html.Element &&
            vnode.tag.toLowerCase() == dn.tagName.toLowerCase()) {
          return source.hasNoRemove;
        }
        break;
      case VdomNodeType.text:
        if (vnode is VdomText && dn is html.Text) {
          return source.hasNoRemove;
        }
        break;
    }
    return false;
  }

  html.Node _createDom(VdomNode vnode) {
    if (vnode?.type == null) {
      throw new Exception('Unknown vnode: $vnode');
    }
    switch (vnode.type) {
      case VdomNodeType.element:
        if (vnode is VdomElement) {
          return new html.Element.tag(vnode.tag);
        }
        break;
      case VdomNodeType.text:
        if (vnode is VdomText) {
          return new html.Text(vnode.value);
        }
        break;
    }
    throw new Exception('Unknown vnode: $vnode');
  }

  void _updateNode(html.Node dn, _VdomSource source, VdomNode vnode) {
    if (vnode?.type == null) {
      throw new Exception('Unknown vnode: $vnode');
    }
    switch (vnode.type) {
      case VdomNodeType.element:
        if (dn is html.Element && vnode is VdomElement) {
          _updateElement(dn, source, vnode);
        }
        break;
      case VdomNodeType.text:
        if (dn is html.Text && vnode is VdomText) {
          _updateText(dn, vnode);
        }
        break;
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
        // Do not override DOM when the value matches the previous one.
        if (source.attributes != null && value == source.attributes[key]) {
          continue;
        }
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
        // Do not override DOM when the value matches the previous one.
        if (source.styles != null && value == source.styles[key]) {
          continue;
        }
        if (dn.style.getPropertyValue(key) != value) {
          dn.style.setProperty(key, value);
        }
      }
    }
    source.styles = vnode.styles;

    final List<_EventSubscription> oldEvents = source.events;
    List<_EventSubscription> newEvents;
    if (vnode.hasEventHandlers) {
      newEvents = vnode.mapEventHandlers((type, reg) {
        if (reg == null) return null;
        if (oldEvents != null) {
          final old = oldEvents.firstWhere(
              (es) =>
                  es.type == type &&
                  es.handler == reg.handler &&
                  es.tracked == reg.tracked,
              orElse: () => null);
          if (old != null) {
            return old;
          }
        }
        final listener = (e) {
          _NoArgFn wrappedHandler(Function handler) {
            if (handler is EventHandler) {
              return () =>
                  handler(new _DomEvent(_view, type, dn, e, boundKeyedRefs));
            } else if (handler is _NoArgFn) {
              return handler;
            } else if (handler is _HtmlEventFn) {
              return () => handler(e);
            } else if (handler is _HtmlEventElementFn) {
              return () => handler(e, dn);
            } else {
              throw new ArgumentError(
                  'Unsupported function signature: $handler');
            }
          }

          final body = wrappedHandler(reg.handler);
          if (reg.tracked) {
            return _view.track(body);
          } else {
            return _view.escape(body);
          }
        };
        return new _EventSubscription(type, listener, reg.handler, reg.tracked);
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

    if (vnode.innerHtml != null) {
      if (source.innerHtml != vnode.innerHtml) {
        source.innerHtml = vnode.innerHtml;
        dn.innerHtml = vnode.innerHtml;
      }
      if (vnode.children != null && vnode.children.isNotEmpty) {
        throw new ArgumentError(
            'Element with innerHtml must not have other vnode children.');
      }
    } else {
      if (source.innerHtml != null) {
        source.innerHtml = null;
      }
      _update(dn, vnode.children);
    }
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

typedef _NoArgFn();
typedef _HtmlEventFn(html.Event event);
typedef _HtmlEventElementFn(html.Event event, html.Element element);

class _DomEvent implements EventContext {
  final View _view;
  final String _type;
  final html.Element _element;
  final html.Event _event;
  final Map _nodesBySymbol;
  _DomEvent(
      this._view, this._type, this._element, this._event, this._nodesBySymbol);

  @override
  View get view => _view;

  @override
  String get type => _type;

  @override
  html.Element get element => _element;

  @override
  dynamic get event => _event;

  N getNode<N>(Symbol symbol) {
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
  })  : _tag = tag ?? 'div',
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
  String innerHtml;

  List<_EventSubscription> events;
  List<_ContextCallbackFn> onRemove;

  bool get hasNoRemove => (onRemove == null || onRemove.isEmpty);
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
