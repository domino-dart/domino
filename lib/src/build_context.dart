import '../domino.dart';

class AncestorBuildContext implements BuildContext {
  final List _ancestors = [];

  @override
  Iterable get ancestors => _ancestors.reversed;

  void pushAncestor(item) {
    _ancestors.add(item);
  }

  popAncestor() => _ancestors.removeLast();
}

List<Node> flattenWithContext(AncestorBuildContext context, dynamic item,
    {List<Node> nodes}) {
  if (item == null) {
    return nodes;
  }
  nodes ??= [];
  if (item is String) {
    nodes.add(new Text(item));
  } else if (item is Node) {
    nodes.add(item);
  } else if (item is Iterable) {
    for (var child in item) {
      flattenWithContext(context, child, nodes: nodes);
    }
  } else if (item is BuildFn) {
    flattenWithContext(context, item(context), nodes: nodes);
  } else if (item is Component) {
    context.pushAncestor(item);
    flattenWithContext(context, item.build(context), nodes: nodes);
    context.popAncestor();
  } else {
    throw new Exception('Unknown child: $item');
  }
  return nodes;
}
