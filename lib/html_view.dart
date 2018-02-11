import 'dart:async';
import 'dart:html' as html;

import 'package:async_tracker/async_tracker.dart';

import 'domino.dart';
import 'src/build_context.dart';

/// Register [children] (e.g. single [Component] or list of [Component] and
/// [Node]s) to the [container] Element and start a [View].
View registerHtmlView(html.Element container, dynamic children) {
  return new _View(container, children);
}

class _View implements View {
  final Expando<List<_EventSubscription>> _eventsExpando = new Expando();
  final Expando<dynamic> _keyExpando = new Expando();
  final Expando<List<AfterCallback>> _onRemoveExpando = new Expando();

  final html.Element _container;
  final _children;

  AsyncTracker _tracker;

  Future _invalidate;
  bool _isDisposed = false;

  _View(this._container, this._children) {
    _tracker = new AsyncTracker()..addListener(invalidate);
    invalidate();
  }

  @override
  Future invalidate() {
    if (_invalidate != null) {
      return _invalidate;
    }
    _invalidate = new Future.microtask(() {
      try {
        final context = new _BuildContext();
        _update(context, _container, _isDisposed ? const [] : _children);
        context._runCallbacks();
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

  void _update(_BuildContext context, html.Element container, dynamic built) {
    final nodes = flattenWithContext(context, built) ?? const <Node>[];
    for (int i = 0; i < nodes.length; i++) {
      final vnode = nodes[i];
      html.Node domNode;
      for (int j = i; j < container.nodes.length; j++) {
        final dn = container.nodes[j];
        final dkey = _keyExpando[dn];
        if (vnode.key != null && vnode.key == dkey) {
          domNode = dn;
        } else if (dkey == null && _mayUpdate(dn, vnode)) {
          domNode = dn;
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
        _updateNode(context, domNode, vnode);
        if (vnode.hasAfterUpdates) {
          context._onUpdateQueue
              .addAll(vnode.afterUpdates.map((fn) => () => fn(domNode)));
        }
      } else {
        final dn = _createDom(context, vnode);
        if (i < container.nodes.length) {
          container.nodes.insert(i, dn);
        } else {
          container.append(dn);
        }
        if (vnode.hasAfterInserts) {
          context._onInsertQueue
              .addAll(vnode.afterInserts.map((fn) => () => fn(dn)));
        }
        if (vnode.hasAfterRemoves) {
          _onRemoveExpando[dn] = vnode.afterRemoves.toList();
        }
      }
    }

    // delete extra DOM nodes
    while (nodes.length < container.nodes.length) {
      _removeAll(context, container.nodes.removeLast());
    }
  }

  bool _mayUpdate(html.Node dn, Node vnode) {
    bool _hasNoEvents() {
      return _eventsExpando[dn] == null && _onRemoveExpando[dn] == null;
    }

    if (vnode is Element &&
        dn is html.Element &&
        vnode.tag.toLowerCase() == dn.tagName.toLowerCase()) {
      return _hasNoEvents();
    } else if (vnode is Text && dn is html.Text) {
      return _hasNoEvents();
    } else {
      return false;
    }
  }

  html.Node _createDom(_BuildContext context, Node vnode) {
    if (vnode is Text) {
      final dn = new html.Text(vnode.text);
      _updateNode(context, dn, vnode);
      return dn;
    } else if (vnode is Element) {
      final dn = new html.Element.tag(vnode.tag);
      _updateElement(context, dn, vnode);
      return dn;
    } else {
      throw new Exception('Unknown vnode: $vnode');
    }
  }

  void _updateNode(_BuildContext context, html.Node dn, Node vnode) {
    if (dn is html.Text && vnode is Text) {
      _updateText(dn, vnode);
    } else if (dn is html.Element && vnode is Element) {
      _updateElement(context, dn, vnode);
    }
    if (vnode.key != null) {
      _keyExpando[dn] = vnode.key;
    }
  }

  void _updateText(html.Text dn, Text vnode) {
    if (!identical(dn.text, vnode.text)) {
      dn.text = vnode.text;
    }
  }

  void _updateElement(_BuildContext context, html.Element dn, Element vnode) {
    if (vnode.attrs != null) {
      for (String key in vnode.attrs.keys) {
        final String value = vnode.attrs[key];
        if (dn.getAttribute(key) != value) {
          if (value == null) {
            dn.attributes.remove(key);
          } else {
            dn.setAttribute(key, value);
          }
        }
      }
    }

    if (vnode.hasClasses) {
      List<String> addList, removeList;
      List<String> classes = vnode.classes.toList();
      for (String s in classes) {
        if (!dn.classes.contains(s)) {
          addList ??= [];
          addList.add(s);
        }
      }
      if (addList != null || classes.length != dn.classes.length) {
        for (String s in dn.classes) {
          if (!classes.contains(s)) {
            removeList ??= [];
            removeList.add(s);
          }
        }
      }

      if (addList != null) {
        dn.classes.addAll(addList);
      }
      if (removeList != null) {
        removeList.forEach(dn.classes.remove);
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

    final List<_EventSubscription> oldEvents = _eventsExpando[dn];
    List<_EventSubscription> newEvents;
    if (vnode.hasEventHandlers) {
      newEvents = vnode
          .mapEventHandlers((type, handler) {
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
              return _tracker.run(() => handler(new _DomEvent(dn, e)));
            };
            return new _EventSubscription(type, listener, handler);
          })
          .where((es) => es != null)
          .toList();
    }
    oldEvents
        ?.where((es) => newEvents == null || !newEvents.contains(es))
        ?.forEach((es) => dn.removeEventListener(es.type, es.listener));
    newEvents
        ?.where((es) => oldEvents == null || !oldEvents.contains(es))
        ?.forEach((es) => dn.addEventListener(es.type, es.listener));

    if (newEvents != null || oldEvents != null) {
      _eventsExpando[dn] = newEvents;
    }

    context._ancestors.add(vnode);
    _update(context, dn, vnode.children);
    context._ancestors.removeLast();
  }

  void _removeAll(_BuildContext context, html.Node node) {
    final List<_EventSubscription> oldEvents = _eventsExpando[node];
    if (oldEvents != null) {
      for (var es in oldEvents) {
        node.removeEventListener(es.type, es.listener);
      }
    }

    final List<AfterCallback> onRemoveCallbacks = _onRemoveExpando[node];
    if (onRemoveCallbacks != null) {
      context._onRemoveQueue
          .addAll(onRemoveCallbacks.map((fn) => () => fn(node)));
    }

    if (node.hasChildNodes()) {
      for (var child in node.nodes) {
        _removeAll(context, child);
      }
    }
  }
}

class _EventSubscription {
  final String type;
  final Function listener;
  final EventHandler handler;

  _EventSubscription(this.type, this.listener, this.handler);
}

typedef void _ContextCallbackFn();

class _BuildContext extends AncestorBuildContext {
  final List _ancestors = [];
  final List<_ContextCallbackFn> _onInsertQueue = [];
  final List<_ContextCallbackFn> _onUpdateQueue = [];
  final List<_ContextCallbackFn> _onRemoveQueue = [];

  void _runCallbacks() {
    _onInsertQueue.forEach((fn) => fn());
    _onUpdateQueue.forEach((fn) => fn());
    _onRemoveQueue.forEach((fn) => fn());
  }

  @override
  Iterable get ancestors => _ancestors.reversed;
}

class _DomEvent implements Event {
  final html.Element _element;
  final html.Event _event;
  _DomEvent(this._element, this._event);

  @override
  dynamic get domElement => _element;

  @override
  dynamic get domEvent => _event;

  @override
  bool get defaultPrevented => _event.defaultPrevented;

  @override
  void preventDefault() => _event.preventDefault();

  @override
  void stopImmediatePropagation() => _event.stopImmediatePropagation();

  @override
  void stopPropagation() => _event.stopPropagation();
}
