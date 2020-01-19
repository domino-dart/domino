List<R> unfold<R>(content) {
  final list = <R>[];
  _unfoldList(list, content);
  return list;
}

void _unfoldList<R>(List<R> list, content) {
  if (content == null) {
    return;
  }
  if (content is Iterable) {
    for (var child in content) {
      if (child == null) continue;
      if (child is Iterable) {
        _unfoldList(list, child);
      } else {
        list.add(child as R);
      }
    }
    return;
  } else {
    list.add(content as R);
  }
}

typedef bool BoolFn();
