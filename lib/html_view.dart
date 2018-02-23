import 'dart:async';
import 'dart:html' as html;

import 'package:async_tracker/async_tracker.dart';

import 'domino.dart';
import 'src/build_context.dart';
import 'src/vdom.dart';

export 'domino.dart';

/// Register [content] (e.g. single [Component] or list of [Component] and
/// [Node]s) to the [container] Element and start a [View].
View registerHtmlView(html.Element container, dynamic content) {
  return new _View(container, content);
}

class _View implements View {
  final Expando<List<_EventSubscription>> _eventsExpando = new Expando();
  final Expando<dynamic> _keyExpando = new Expando();
  final Expando<List<_ContextCallbackFn>> _onRemoveExpando = new Expando();

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
      for (int j = i; j < container.nodes.length; j++) {
        final dn = container.nodes[j];
        final dkey = _view._keyExpando[dn];
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
        _updateNode(domNode, vnode);
        if (vnode.hasAfterUpdates) {
          final c = new _Change(ChangePhase.update, domNode);
          final list =
              vnode.changes[ChangePhase.update].map((fn) => () => fn(c));
          _onUpdateQueue.addAll(list);
        }
      } else {
        final dn = _createDom(vnode);
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
          _view._onRemoveExpando[dn] = vnode.changes[ChangePhase.remove]
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

  bool _mayUpdate(html.Node dn, VdomNode vnode) {
    bool _hasNoEvents() {
      return _view._eventsExpando[dn] == null &&
          _view._onRemoveExpando[dn] == null;
    }

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
      return _hasNoEvents();
    } else if (vnode is VdomText && dn is html.Text) {
      return _hasNoEvents();
    } else {
      return false;
    }
  }

  html.Node _createDom(VdomNode vnode) {
    if (vnode is VdomText) {
      final dn = new html.Text(vnode.value);
      _updateNode(dn, vnode);
      return dn;
    } else if (vnode is VdomElement) {
      final dn = new html.Element.tag(vnode.tag);
      _updateElement(dn, vnode);
      return dn;
    } else {
      throw new Exception('Unknown vnode: $vnode');
    }
  }

  void _updateNode(html.Node dn, VdomNode vnode) {
    if (dn is html.Text && vnode is VdomText) {
      _updateText(dn, vnode);
    } else if (dn is html.Element && vnode is Element) {
      _updateElement(dn, vnode);
    }
    if (vnode.key != null) {
      _view._keyExpando[dn] = vnode.key;
    }
  }

  void _updateText(html.Text dn, VdomText vnode) {
    if (!identical(dn.text, vnode.value)) {
      dn.text = vnode.value;
    }
  }

  void _updateElement(html.Element dn, VdomElement vnode) {
    final boundKeyedRefs = vnode.keyedRefs?.bind(vnode.key, dn);

    final Set<String> attrsToRemove = dn.attributes.keys.toSet();
    if (vnode.hasClasses) {
      attrsToRemove.remove('class');
    }
    if (vnode.styles != null) {
      attrsToRemove.remove('style');
    }

    if (vnode.attributes != null) {
      for (String key in vnode.attributes.keys) {
        attrsToRemove.remove(key);
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
    for (String attr in attrsToRemove) {
      dn.attributes.remove(attr);
    }

    List<String> addList, removeList;
    List<String> classes = vnode.classes?.toList() ?? const <String>[];
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

    if (vnode.styles != null) {
      for (String key in vnode.styles.keys) {
        final String value = vnode.styles[key];
        if (dn.style.getPropertyValue(key) != value) {
          dn.style.setProperty(key, value);
        }
      }
    }

    final List<_EventSubscription> oldEvents = _view._eventsExpando[dn];
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
      _view._eventsExpando[dn] = newEvents;
    }

    _update(dn, vnode.children);
  }

  void _removeAll(html.Node node) {
    final List<_EventSubscription> oldEvents = _view._eventsExpando[node];
    if (oldEvents != null) {
      for (var es in oldEvents) {
        node.removeEventListener(es.type, es.listener);
      }
    }

    final List<_ContextCallbackFn> onRemoveCallbacks =
        _view._onRemoveExpando[node];
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
  final Map _keyedNodes;
  _DomEvent(this._type, this._element, this._event, this._keyedNodes);

  @override
  String get type => _type;

  @override
  html.Element get element => _element;

  @override
  dynamic get event => _event;

  html.Node getByKey(key) {
    if (_keyedNodes == null) return null;
    return _keyedNodes[key];
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
