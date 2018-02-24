Iterable<R> unfold<R>(content) sync* {
  if (content == null) {
    return;
  }
  if (content is Iterable) {
    for (var child in content) {
      if (child == null) continue;
      if (child is Iterable) {
        yield* unfold(child);
        continue;
      }
      yield child;
    }
    return;
  }
  yield content;
}
