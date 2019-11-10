Iterable<R> unfold<R>(content) sync* {
  if (content == null) {
    return;
  }
  if (content is Iterable) {
    for (var child in content) {
      if (child == null) continue;
      if (child is Iterable) {
        yield* unfold(child);
      } else {
        yield child as R;
      }
    }
    return;
  } else {
    yield content as R;
  }
}

typedef bool BoolFn();
