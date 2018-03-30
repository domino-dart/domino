import '../domino.dart';

import '_unfold.dart';

/// Adds a style to an [Element] with [_name] and [_value]
///
/// Example:
///     div(set: style('color', 'blue'))
class StyleSetter implements Setter {
  final String _name;

  final String _value;

  const StyleSetter(this._name, this._value);

  void apply(ElementProxy e) => e.setStyle(_name, _value);
}

/// Adds a attribute to an [Element] with [_name] and [_value]
///
/// Example:
///     div(set: attr('id', 'main'))
class AttrSetter implements Setter {
  final String _name;

  final String _value;

  const AttrSetter(this._name, this._value);

  void apply(ElementProxy e) => e.setAttribute(_name, _value);
}

/// Adds classes to an [Element]
///
/// Example:
///     div(set: clazz('main'))
class ClassAdder implements Setter {
  final List<String> _classes;

  ClassAdder(class1, [class2, class3, class4, class5])
      : _classes =
            unfold<String>([class1, class2, class3, class4, class5]).toList();

  void apply(ElementProxy e) => _classes.forEach(e.addClass);
}

/// Adds an [handler] to an [Element] for event [type]
///
/// Example:
///     div(set: on('click', () => print('Clicked!')))
class EventSetter implements Setter {
  final String _type;
  final EventHandler _handler;
  final bool _tracked;

  const EventSetter(String type, EventHandler handler, {bool tracked})
      : _type = type,
        _handler = handler,
        _tracked = tracked ?? true;

  void apply(ElementProxy e) => e.addEventHandler(_type, _handler, _tracked);
}

class LifecycleSetter implements Setter {
  final ChangePhase _phase;
  final ChangeHandler _handler;
  const LifecycleSetter(ChangePhase phase, ChangeHandler handler)
      : _phase = phase,
        _handler = handler;

  @override
  void apply(ElementProxy proxy) {
    proxy.addChangeHandler(_phase, _handler);
  }
}

class InnerHtmlSetter implements Setter {
  final String _html;
  InnerHtmlSetter(String html) : _html = html;

  @override
  void apply(ElementProxy proxy) {
    proxy.setInnerHtml(_html);
  }
}
