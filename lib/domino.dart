import 'dart:async';

export 'src/element/element.dart';

/// The context of the current build.
abstract class BuildContext {
  /// List of ancestor [Element]s or [Component]s. Ordered from the bottom
  /// (direct parent) to the top (root [Component] or [Element]).
  Iterable get ancestors;
}

/// Builds a single or List-embedded structure of Nodes and/or Components.
typedef dynamic BuildFn(BuildContext context);

/// A state-holder component that builds a single or List-embedded structure of
/// Nodes and/or Components.
abstract class Component {
  /// Builds a single or List-embedded structure of Nodes and/or Components.
  dynamic build(BuildContext context);
}

/// Provides lifecycle handling for a hierarchy of components.
abstract class View {
  /// Schedule an update of the [View].
  Future invalidate();

  /// Dispose the [View] and free resources.
  Future dispose();
}
