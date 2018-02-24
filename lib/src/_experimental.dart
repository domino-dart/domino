//import 'domino.dart';

///// Stateful (but disposable) [Component] that provides lifecycle hooks to store
///// and retrieve its state.
//abstract class StatefulComponent<S> extends Component {
//  /// Gets the state of the component.
//  ///
//  /// The getter will be called only before the a rebuild requires it.
//  S getState();
//
//  /// Set the state of the component.
//  ///
//  /// The setter will be called right before [build] is called. [value] will be
//  /// either the value from the previous instance's [getState] call, or null.
//  void setState(S value);
//}

///// A component that can restore its state from a previous build:
///// - [prev.component] == the previous instance of the component
///// - [next.component] == this
//abstract class StatefulComponent implements Component {
//  void restoreState(BuildContext prev, BuildContext next);
//}
