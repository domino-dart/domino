import 'package:meta/meta.dart';

typedef LifecycleCallback<L> = Function(LifecycleEvent<L> element);
typedef DomEventFn<V> = Function(DomEvent<V> event);
typedef SlotFn = void Function(DomContext $d);

abstract class DomContext<L, V> {
  L get element;
  dynamic get pointer;

  void open(
    String tag, {
    String key,
    LifecycleCallback<L> onCreate,
    LifecycleCallback<L> onRemove,
  });

  void attr(String name, String value);
  void style(String name, String value);
  void clazz(String name, {bool present = true});

  void event(
    String name, {
    @required DomEventFn<V> fn,
    String key,
    bool tracked = true,
  });

  void text(String value);
  void innerHtml(String value);

  void skipNode();
  void skipRemainingNodes();

  void close({String tag});
}

abstract class LifecycleEvent<L> {
  L get element;

  void triggerUpdate();
}

abstract class DomEvent<V> {
  V get event;

  void triggerUpdate();
}

