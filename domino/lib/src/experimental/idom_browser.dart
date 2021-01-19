import 'dart:async';
import 'dart:html';

import 'idom.dart';

void patch(
  Element host,
  Function(DomContext ctx) fn, {
  DomContextGlobals globals,
}) {
  final ctx = BrowserDomContext(host, globals: globals);
  fn(ctx);
  ctx.cleanup();
}

class BrowserDomContext implements DomContext<Element, Event> {
  @override
  final DomContextGlobals globals;
  final Element _hostElement;
  final _lifecycleEvents = <_LifecycleEventData>[];
  final _positions = <_ElemPos>[];
  final _removedNodes = <Node>[];

  BrowserDomContext(
    Element host, {
    DomContextGlobals globals,
  })  : _hostElement = host,
        globals = globals ?? DomContextGlobals() {
    reset();
  }

  void reset() {
    _lifecycleEvents.clear();
    _positions.clear();
    //assert(_hostElement.styleMap != null); // TODO: error, why null?
    _positions.add(_ElemPos(_hostElement));
    _removedNodes.clear();
  }

  Future<void> cleanup() async {
    close();

    // TODO: queue removed callbacks to lifecycle events

    while (_lifecycleEvents.isNotEmpty) {
      final list = [..._lifecycleEvents];
      _lifecycleEvents.clear();

      for (final data in list) {
        await data._fn(_LifecycleEvent(data._elem));
      }
    }
  }

  @override
  Element get element => _positions.last.elem;

  @override
  dynamic get pointer => _positions.last.currentNode;

  @override
  void open(
    String tag, {
    String key,
    LifecycleCallback<Element> onCreate,
    LifecycleCallback<Element> onRemove,
  }) {
    final pos = _positions.last;

    // match current element
    final currentNode = pos.currentNode;
    final currentElem = currentNode is Element ? currentNode : null;
    final currentExtra = currentElem == null ? null : _elemExpando[currentElem];
    final matchesCurrentElem =
        currentElem?.tagName?.toLowerCase() == tag.toLowerCase() &&
            currentExtra?.key == key;
    if (matchesCurrentElem) {
      _positions.add(_ElemPos(currentElem));
      return;
    }

    if (key != null) {
      // match tag + key after the current position
      final matchedElem = pos.elem.children.skip(pos.index).firstWhere(
          (n) =>
              n is Element &&
              n.tagName.toLowerCase() == tag.toLowerCase() &&
              _elemExpando[n]?.key == key,
          orElse: () => null);
      if (matchedElem != null) {
        if (pos.elem.nodes.indexOf(matchedElem) != pos.index) {
          matchedElem.remove();
          pos.insert(matchedElem);
        }
        _positions.add(_ElemPos(matchedElem));
        return;
      }
    } else {
      // otherwise match tag of an element (without any key)
      final matchedElem = pos.elem.children.skip(pos.index).firstWhere(
          (n) =>
              n is Element &&
              n.tagName.toLowerCase() == tag.toLowerCase() &&
              _elemExpando[n]?.key == null,
          orElse: () => null);

      if (matchedElem != null) {
        if (pos.elem.nodes.indexOf(matchedElem) != pos.index) {
          matchedElem.remove();
          pos.insert(matchedElem);
        }
        _positions.add(_ElemPos(matchedElem));
        return;
      }
    }

    // fallback: create new Element
    final newElem = Element.tag(tag);
    if (key != null || onCreate != null || onRemove != null) {
      _elemExpando[newElem] = _ElemExtra()
        ..key = key
        ..onCreate = onCreate
        ..onRemove = onRemove;
      // TODO: set cascade remove on parents
    }
    pos.insert(newElem);
    _positions.add(_ElemPos(newElem));
    if (onCreate != null) {
      _lifecycleEvents.add(_LifecycleEventData(newElem, onCreate));
    }
  }

  @override
  void attr(String name, String value) {
    final pos = _positions.last;
    pos._attrsToRemove?.remove(name);

    final elem = pos.elem;
    final current = elem.attributes[name];
    if (value == null && current != null) {
      elem.attributes.remove(name);
    } else if (value != null && current != value) {
      elem.attributes[name] = value;
    }
  }

  @override
  void clazz(String name, {bool present = true}) {
    final pos = _positions.last;
    pos._classesToRemove?.remove(name);

    final elem = pos.elem;
    final contains = elem.classes.contains(name);
    if (present && !contains) {
      elem.classes.add(name);
    } else if (!present && contains) {
      elem.classes.remove(name);
    }
  }

  @override
  void style(String name, String value) {
    final pos = _positions.last;
    pos._stylesToRemove?.remove(name);

    final elem = pos.elem;
    final current = elem.style.getPropertyValue(name);
    if (value == null && current != null) {
      elem.styleMap.delete(name);
    } else if (value != null && current != value) {
      elem.style.setProperty(name, value);
    }
  }

  @override
  void text(String value) {
    final pos = _positions.last;
    final currentNode = pos.currentNode;
    if (currentNode is Text && currentNode.text == value) {
      pos.index++;
    } else if (currentNode is Text) {
      currentNode.text = value;
      pos.index++;
    } else {
      pos.insert(Text(value));
      pos.index++;
    }
  }

  @override
  void innerHtml(String value) {
    final pos = _positions.last;
    pos.elem.setInnerHtml(value);
    skipRemainingNodes();
  }

  @override
  void event(String name,
      {DomEventFn<Event> fn, String key, bool tracked = true}) {
    final elem = element;
    _elemExpando[elem] ??= _ElemExtra();
    final extra = _elemExpando[elem];
    final ekey = '$name[$key]';
    extra.eventSubscriptions ??= <String, StreamSubscription>{};
    final contains = extra.eventSubscriptions.containsKey(ekey);
    if (fn == null && contains) {
      extra.eventSubscriptions.remove(ekey).cancel();
    } else if (fn != null && !contains) {
      // TODO: set tracker
      extra.eventSubscriptions[ekey] = elem.on[name].listen((e) {
        fn(_DomEvent(e));
      });
    }
  }

  @override
  void skipNode() {
    final pos = _positions.last;
    if (pos.index < pos.elem.nodes.length) {
      pos.index++;
    }
  }

  @override
  void skipRemainingNodes() {
    final pos = _positions.last;
    pos.index = pos.elem.nodes.length;
  }

  @override
  void close({String tag}) {
    final pos = _positions.removeLast();
    if (tag != null && pos.elem.tagName.toLowerCase() != tag.toLowerCase()) {
      throw StateError(
          'Closing tag: $tag != Element tag: ${pos.elem.tagName.toLowerCase()}');
    }
    if (pos._classesToRemove != null && pos._classesToRemove.isNotEmpty) {
      pos.elem.classes.removeAll(pos._classesToRemove);
    }
    if (pos._stylesToRemove != null && pos._stylesToRemove.isNotEmpty) {
      for (final style in pos._stylesToRemove) {
        pos.elem.style.removeProperty(style);
      }
    }
    if (pos._attrsToRemove != null && pos._attrsToRemove.isNotEmpty) {
      for (final attr in pos._attrsToRemove) {
        pos.elem.removeAttribute(attr);
      }
    }
    for (var i = pos.elem.nodes.length - pos.index; i > 0; i--) {
      final n = pos.elem.nodes.removeLast();
      _removedNodes.add(n);
    }
    if (_positions.isNotEmpty) {
      _positions.last.index++;
    }
  }
}

class _ElemPos {
  final Element elem;
  final Set<String> _classesToRemove;
  final Set<String> _stylesToRemove;
  final Set<String> _attrsToRemove;
  int index = 0;

  _ElemPos(this.elem)
      : _classesToRemove =
            elem.hasAttribute('class') ? elem.classes.toSet() : null,
        _stylesToRemove = elem.styleMap?.getProperties()?.toSet(),
        _attrsToRemove =
            elem.attributes.isEmpty ? null : elem.attributes.keys.toSet() {
    _attrsToRemove?.remove('class');
    _attrsToRemove?.remove('style');
  }

  Node get currentNode {
    return index < elem.nodes.length ? elem.nodes[index] : null;
  }

  void insert(Node node) {
    if (index < elem.nodes.length) {
      elem.insertBefore(node, currentNode);
    } else {
      elem.append(node);
    }
  }
}

class _ElemExtra {
  Map<String, StreamSubscription> eventSubscriptions;
  bool cascadeRemove = false;
  String key;
  LifecycleCallback<Element> onCreate;
  LifecycleCallback<Element> onRemove;
}

final _elemExpando = Expando<_ElemExtra>('extra');

class _LifecycleEventData {
  final Element _elem;
  final LifecycleCallback<Element> _fn;

  _LifecycleEventData(this._elem, this._fn);
}

class _LifecycleEvent extends LifecycleEvent<Element> {
  @override
  final Element element;

  _LifecycleEvent(this.element);

  @override
  void triggerUpdate() {
    // TODO: implement triggerUpdate
  }
}

class _DomEvent extends DomEvent<Event> {
  @override
  final Event event;

  _DomEvent(this.event);

  @override
  void triggerUpdate() {
    // TODO: implement triggerUpdate
  }
}
