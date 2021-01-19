import 'package:domino/src/_unfold.dart';

typedef DNodeListFn = Iterable<DNode> Function();
typedef DEventCallback<L, V> = Function(DEvent<L, V> event);
typedef DLifecycleCallback<L> = Function(DLifecycleEvent<L> event);

/// Provides lifecycle handling for a hierarchy of components.
/// A [DView] re-builds the UI after `invalidate()` is called (or automatically
/// when [DEventCallback]s are registered).
abstract class DView {
  /// Updates the [DView].
  ///
  /// Should be used only as a last resort, use [invalidate] instead.
  void update();

  /// Schedule an update of the [DView], with the returned future completing
  /// when the view is updated to the latest state.
  Future<void> invalidate();

  /// Runs [action] in the [DView]'s tracker zone.
  ///
  /// This zone tracks the execution of [action] and its async callbacks,
  /// triggering the invalidation and (re-)building of the [DView] after each run.
  ///
  /// [DEventCallback]s registered in the [DView] during the build phase will be
  /// using this automatically.
  R track<R>(R Function() action);

  /// Escapes the [DView]'s tracker zone (e.g. from inside an [DEventCallback]),
  /// no longer triggering the invalidation of the [DView] after its run finishes.
  R escape<R>(R Function() action);

  /// Dispose the [DView] and free resources.
  Future dispose();
}

abstract class DVisitor {
  void visitNode(DNode node) {
    if (node == null) return;
    if (node is DComponent) {
      visitComponent(node);
    } else if (node is DElem) {
      visitElem(node);
    } else if (node is DText) {
      visitText(node);
    } else if (node is DInnerHtml) {
      visitInnerHtml(node);
    } else {
      throw AssertionError('Unknown node: $node');
    }
  }

  void visitComponent(DComponent node) {
    for (final n in node.renderNodes()) {
      visitNode(n);
    }
  }

  void visitElem(DElem node);

  void visitText(DText node);

  void visitInnerHtml(DInnerHtml node);
}

// ignore: one_member_abstracts
abstract class DNode {
  void visit(DVisitor visitor);
}

abstract class DComponent extends DNode {
  static DComponent withFn(DNodeListFn fn) => _DComponentWithFn(fn);
  static DComponent ofNodes(List<DNode> nodes) => _DComponentOfNodes(nodes);

  Iterable<DNode> renderNodes();

  @override
  void visit(DVisitor visitor) => visitor.visitComponent(this);
}

class _DComponentWithFn extends DComponent {
  final DNodeListFn _fn;
  _DComponentWithFn(this._fn);

  @override
  Iterable<DNode> renderNodes() => _fn();
}

class _DComponentOfNodes extends DComponent {
  final List<DNode> _nodes;
  _DComponentOfNodes(this._nodes);

  @override
  Iterable<DNode> renderNodes() => _nodes;
}

class DElem extends DNode {
  final String tag;
  final DStringList classes;
  final DStringMap attrs;
  final DStringMap styles;
  final List<DNode> children;
  final Map<String, DEventDefinition> events;
  final DLifecycleCallback onCreate;

  DElem(
    this.tag, {
    this.classes,
    this.attrs,
    this.styles,
    this.children,
    this.events,
    this.onCreate,
  });

  @override
  void visit(DVisitor visitor) => visitor.visitElem(this);

  bool get hasChildren => children != null && children.isNotEmpty;
}

typedef DBoolFn = bool Function();
typedef DStringFn = String Function();

class DStringList {
  final List<String> _values;
  final Map<String, DBoolFn> _ifs;
  final List<DStringFn> _fns;

  DStringList({
    Iterable<String> values,
    Map<String, DBoolFn> ifs,
    Iterable<DStringFn> fns,
  })  : _values = values?.toList(),
        _ifs = ifs,
        _fns = fns?.toList();

  List<String> get asList {
    return <String>[
      if (_values != null) ..._values,
      if (_ifs != null)
        ..._ifs.entries.where((e) => e.value()).map((e) => e.key),
      if (_fns != null)
        ..._fns.map((fn) => fn()).where((v) => v != null && v.isNotEmpty),
    ];
  }
}

class DStringMap {
  final Map<String, String> _values;
  final Map<String, DStringFn> _fns;

  DStringMap({
    Map<String, String> values,
    Map<String, DStringFn> fns,
  })  : _values = values,
        _fns = fns;

  Map<String, String> get values {
    final fnsv = _fns == null
        ? null
        : _fns.entries.map((e) {
            final v = e.value();
            return v == null ? null : MapEntry(e.key, v);
          }).where((e) => e != null);
    return <String, String>{
      if (_values != null) ..._values,
      if (_fns != null) ...Map.fromEntries(fnsv),
    };
  }
}

class DEventDefinition {
  final DEventCallback callback;
  final DBoolFn ifFn;
  final dynamic identityKey;
  final bool escapeTracking;

  DEventDefinition(
    this.callback, {
    this.ifFn,
    this.identityKey,
    this.escapeTracking = false,
  });
}

class DText extends DNode {
  final String _value;
  final String Function() _fn;
  DText(this._value) : _fn = null;
  DText.fn(this._fn) : _value = null;

  @override
  void visit(DVisitor visitor) => visitor.visitText(this);

  String get value => _value ?? _fn();
}

class DInnerHtml extends DNode {
  final String value;
  DInnerHtml(this.value);

  @override
  void visit(DVisitor visitor) => visitor.visitInnerHtml(this);
}

abstract class DLifecycleEvent<L> {
  DView get view;
  L get element;
}

abstract class DEvent<L, V> {
  DView get view;
  L get element;
  V get event;
}

class DIfComponent extends DComponent {
  final List<DIfExpr> exprs;
  final DNodeListFn orElse;

  DIfComponent(this.exprs, {this.orElse});

  @override
  Iterable<DNode> renderNodes() {
    for (final expr in exprs) {
      if (expr.expression()) {
        return expr.nodeListFn();
      }
    }
    if (orElse != null) return orElse();
    return Iterable<DNode>.empty();
  }
}

class DIfExpr {
  final BoolFn expression;
  final DNodeListFn nodeListFn;

  DIfExpr(this.expression, this.nodeListFn);
}

class DForComponent<T> extends DComponent {
  final Iterable<DForExpr> Function() iterable;
  DForComponent(this.iterable);

  @override
  Iterable<DNode> renderNodes() {
    return iterable().map((e) => e._component);
  }
}

class DForExpr {
  final dynamic item;
  final DNodeListFn fn;

  DComponent _component;

  DForExpr(this.item, this.fn);

  DComponent get component => _component ??= DComponent.ofNodes(fn().toList());
}
