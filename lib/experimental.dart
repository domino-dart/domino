import 'domino.dart';

/// Stateful (but disposable) [Component] that provides lifecycle hooks to store
/// and retrieve its state.
abstract class StatefulComponent<S> extends Component {
  /// Gets the state of the component.
  ///
  /// The getter will be called only before the a rebuild requires it.
  S getState();

  /// Set the state of the component.
  ///
  /// The setter will be called right before [build] is called. [value] will be
  /// either the value from the previous instance's [getState] call, or null.
  void setState(S value);
}
