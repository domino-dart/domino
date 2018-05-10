import '../domino.dart';

class EventHandlerReg {
  final Function handler;
  final bool tracked;

  EventHandlerReg(this.handler, this.tracked);
}

enum VdomNodeType { element, text }

/// Node in the vDOM.
abstract class VdomNode {
  VdomNodeType get type;
  Symbol get symbol;
  NodeRefs nodeRefs;

  Map<ChangePhase, List<ChangeHandler>> changes;

  bool get hasAfterUpdates =>
      changes != null && changes.containsKey(ChangePhase.update);
  bool get hasAfterInserts =>
      changes != null && changes.containsKey(ChangePhase.insert);
  bool get hasAfterRemoves =>
      changes != null && changes.containsKey(ChangePhase.remove);
}

class VdomElement extends VdomNode implements ElementProxy {
  @override
  final VdomNodeType type = VdomNodeType.element;

  dynamic tag;

  @override
  Symbol symbol;

  List<String> classes;
  Map<String, String> attributes;
  Map<String, String> styles;
  Map<String, List<EventHandlerReg>> events;
  String innerHtml;

  List<VdomNode> children;

  bool get hasClasses => classes != null && classes.isNotEmpty;
  bool get hasEventHandlers => events != null && events.isNotEmpty;

  @override
  void setSymbol(Symbol symbol) {
    this.symbol = symbol;
  }

  @override
  void addClass(String className) {
    if (className == null) return;
    classes ??= [];
    if (!classes.contains(className)) {
      classes.add(className);
    }
  }

  @override
  void addEventHandler(String type, Function handler, bool tracked) {
    if (handler == null) return;
    events ??= {};
    final list = events.putIfAbsent(type, () => []);
    final alreadyAdded = list
        .where((reg) => reg.tracked == tracked && reg.handler == handler)
        .isNotEmpty;
    if (alreadyAdded) return;
    list.add(new EventHandlerReg(handler, tracked));
  }

  @override
  void setAttribute(String name, String value) {
    if (value == null) return;
    attributes ??= {};
    attributes[name] = value;
  }

  @override
  void setStyle(String name, String value) {
    if (value == null) return;
    styles ??= {};
    styles[name] = value;
  }

  @override
  void setInnerHtml(String html) {
    if (html == null) return;
    innerHtml = html;
  }

  Iterable<R> mapEventHandlers<R>(
      R fn(String type, EventHandlerReg reg)) sync* {
    if (events == null) return;
    for (String type in events.keys) {
      for (EventHandlerReg reg in events[type]) {
        final r = fn(type, reg);
        if (r != null) {
          yield r;
        }
      }
    }
  }

  @override
  void addChangeHandler(ChangePhase type, ChangeHandler handler) {
    if (handler == null) return;
    changes ??= {};
    final list = changes.putIfAbsent(type, () => []);
    if (!list.contains(handler)) {
      list.add(handler);
    }
  }
}

class VdomText extends VdomNode {
  @override
  final VdomNodeType type = VdomNodeType.text;

  final String value;

  VdomText(this.value);

  @override
  Symbol get symbol => null;
}

class NodeRefs {
  final List<VdomNode> _nodes = [];
  final Map _map = {};

  void add(VdomNode node) {
    _nodes.add(node);
  }

  Map bind(key, domNode) {
    if (key != null) {
      _map[key] = domNode;
    }
    return _map;
  }
}
