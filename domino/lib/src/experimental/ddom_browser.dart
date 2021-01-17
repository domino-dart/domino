import 'dart:async';
import 'dart:collection';
import 'dart:html' as html;

import 'package:async_tracker/async_tracker.dart';

import 'ddom.dart';

/// Binds [content] to the [container] Element and start a [DView].
DView bindHtmlView(html.Element container, DNodeListFn content) {
  return _View(container, content);
}

class _View implements DView {
  final html.Element _container;
  final DNodeListFn _content;

  AsyncTracker _tracker;

  Future _invalidate;
  bool _isDisposed = false;

  _View(this._container, this._content) {
    _tracker = AsyncTracker()..addListener(invalidate);
    invalidate();
  }

  @override
  R track<R>(R Function() action) => _tracker.run(action);

  @override
  R escape<R>(R Function() action) => _tracker.parentZone.run(action);

  @override
  Future invalidate() {
    _invalidate ??= Future.delayed(Duration.zero, () {
      try {
        _update();
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

  void _update() {
    final updater = _ViewUpdater(this, _container);
    updater._visit(_isDisposed ? () => <DNode>[] : _content);
    updater._runCallbacks();
  }
}

class _ViewUpdater extends DVisitor {
  final _View _view;
  final html.Element _container;
  final _onCreateQueue = <Function>[];
  final _stack = Queue<_Pos>();

  _ViewUpdater(this._view, this._container);

  void _runCallbacks() {
    _onCreateQueue.forEach((fn) => fn());
  }

  void _visit(DNodeListFn content) {
    _stack.add(_Pos(_container, 0));
  }

  @override
  void visitElem(DElem node) {
    final cursor = _stack.last;
    final c = cursor.currentNode;
    if (c is html.Element && c.tagName == node.tag) {
      cursor.skip();
      _visitElem(node, c);
    } else {
      final elem = html.Element.tag(node.tag);
      if (node.onCreate != null) {
        _onCreateQueue.add(() => node.onCreate(_DLifecycleEvent(_view, elem)));
      }
      cursor.insertBefore(elem, c);
      _visitElem(node, elem);
    }
  }

  void _visitElem(DElem node, html.Element elem) {
    final classes = node.classes?.asList;
    if ((classes == null || classes.isEmpty) && elem.hasAttribute('class')) {
      elem.removeAttribute('class');
    } else if (classes != null && classes.isNotEmpty) {
      final v = classes.join(' ');
      if (elem.getAttribute('class') != v) {
        elem.setAttribute('class', v);
      }
    }

    final styles = node.styles?.values;
    if ((styles == null || styles.isEmpty) && elem.hasAttribute('style')) {
      elem.removeAttribute('style');
    } else if (styles != null && styles.isNotEmpty) {
      final sm = elem.styleMap;
      final remove = sm.getProperties().toSet();
      styles.forEach((key, value) {
        remove.remove(key);
        final v = sm.get(key)?.toString();
        if (v != value) {
          sm.set(key, value);
        }
      });
      remove.forEach((r) => sm.delete(r));
    }

    final attrs = node.attrs?.values ?? const <String, String>{};
    final removeAttrs = elem.attributes.keys.toSet()
      ..remove('class')
      ..remove('style');
    attrs.forEach((key, value) {
      removeAttrs.remove(key);
      final v = elem.attributes[key];
      if (v != value) {
        elem.attributes[key] = value;
      }
    });
    removeAttrs.forEach((r) => elem.removeAttribute(r));

    if (node.hasChildren) {
      _stack.add(_Pos(elem, 0));
      for (final n in node.children) {
        visitNode(n);
      }
      final cc = _stack.removeLast();
      cc.clear();
    }

    final oldNodeExt = _getHtmlNodeExt(elem);
    var nodeExt = oldNodeExt;
    void initNodeExt() {
      if (nodeExt == null) {
        nodeExt = _HtmlNodeExt();
        _setHtmlNodeExt(elem, nodeExt);
      }
    }

    final removeEvents = oldNodeExt?.boundEvents?.keys?.toSet();
    if (node.events != null) {
      initNodeExt();

      node.events.forEach((event, definition) {
        if (definition.ifFn != null && !definition.ifFn()) return;
        removeEvents?.remove(event);

        final oldBound = nodeExt.boundEvents[event];
        if (oldBound != null &&
            definition.identityKey == oldBound.definition.identityKey) {
          return;
        }
        if (definition == oldBound?.definition) {
          return;
        }

        final eventListener = (html.Event e) {
          final DEvent de = _DEvent(_view, elem, e);
          if (definition.escapeTracking ?? false) {
            _view.track(() => definition.callback(de));
          } else {
            _view.escape(() => definition.callback(de));
          }
        };
        elem.addEventListener(event, eventListener);
        nodeExt.boundEvents[event] = _BoundEvent(definition, eventListener);
      });
    }
    removeEvents?.forEach((event) {
      final be = nodeExt.boundEvents.remove(event);
      elem.removeEventListener(event, be.eventListener);
    });
  }

  @override
  void visitText(DText node) {
    final cursor = _stack.last;
    final c = cursor.currentNode;
    if (c is html.Text) {
      c.text = node.value;
      cursor.skip();
    } else {
      cursor.insertBefore(html.Text(node.value), c);
    }
  }

  @override
  void visitInnerHtml(DInnerHtml node) {
    final cursor = _stack.last;
    cursor.parent.innerHtml = node.value;
    cursor.skipAll();
  }
}

class _Pos {
  final html.Element parent;
  int index;

  _Pos(this.parent, this.index);

  html.Node get currentNode {
    final nodes = parent.nodes;
    if (nodes.length <= index) return null;
    return nodes[index];
  }

  void insertBefore(html.Node node, html.Node child) {
    if (child == null) {
      parent.append(node);
    } else {
      parent.insertBefore(node, child);
    }
    index++;
  }

  void skip() {
    index++;
  }

  void skipAll() {
    index = parent.nodes.length;
  }

  void clear() {
    while (parent.nodes.length > index) {
      parent.nodes.removeLast();
    }
  }
}

class _HtmlNodeExt {
  final boundEvents = <String, _BoundEvent>{};
}

class _BoundEvent {
  final DEventDefinition definition;
  final html.EventListener eventListener;

  _BoundEvent(this.definition, this.eventListener);
}

final Expando<_HtmlNodeExt> _htmlNodeExtExpando = Expando();

_HtmlNodeExt _getHtmlNodeExt(html.Node node) {
  return _htmlNodeExtExpando[node];
}

void _setHtmlNodeExt(html.Node node, _HtmlNodeExt ext) {
  _htmlNodeExtExpando[node] = ext;
}

class _DEvent implements DEvent {
  @override
  final DView view;
  @override
  final html.Element element;
  @override
  final html.Event event;

  _DEvent(this.view, this.element, this.event);
}

class _DLifecycleEvent implements DLifecycleEvent {
  @override
  final DView view;

  @override
  final html.Element element;

  _DLifecycleEvent(this.view, this.element);
}
