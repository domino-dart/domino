Iterable<R> unfold<R>(content) sync* {
  if (content == null) {
    return;
  }
  if (content is Iterable) {
    for (var child in content) {
      if (child == null) continue;
      if (child is Iterable) {
        yield* unfold(child);
      } else if (child is Conditional) {
        yield* child.unfoldConditional();
      } else {
        yield child as R;
      }
    }
    return;
  } else if (content is Conditional) {
    yield* content.unfoldConditional();
    return;
  }
  yield content as R;
}

typedef bool BoolFn();

class Conditional {
  final _cond;
  final _then;
  final _orElse;

  Conditional(this._cond, this._then, this._orElse);

  Iterable<R> unfoldConditional<R>() sync* {
    final evaluated = evaluate();
    var items = evaluated ? _then : _orElse;
    if (items is Function) {
      items = items();
    }
    yield* unfold(items);
  }

  bool evaluate() {
    if (_cond == null) return false;
    if (_cond is bool) return _cond as bool;
    if (_cond is Function) {
      final v = _cond();
      if (v is bool) return v;
      return false;
    }
    return false;
  }
}
