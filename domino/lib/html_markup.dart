import 'dart:async';
import 'dart:convert';

import 'domino.dart';
import 'src/legacy/_build_context.dart';
import 'src/legacy/_vdom.dart';

final _attrEscaper = HtmlEscape(HtmlEscapeMode.attribute);
final _textEscaper = HtmlEscape(HtmlEscapeMode.element);

/// Builds HTML markup based on the hierarchy of [Component]s and [Element]s.
/// Intended mostly for testing, but it could work as a server-side renderer too.
class HtmlMarkupBuilder {
  final String? indent;
  final bool _hasIndent;
  HtmlMarkupBuilder({this.indent})
      : _hasIndent = indent != null && indent.isNotEmpty;

  String convert(dynamic item) {
    final buffer = StringBuffer();
    final nodes = BuildContextImpl(_HtmlMarkupView()).buildNodes(item);
    _writeTo(buffer, nodes);
    return buffer.toString().trim();
  }

  void _writeTo(StringSink sink, List<VdomNode>? nodes, {int level = 0}) {
    if (nodes == null) return;
    for (final node in nodes) {
      if (_hasIndent) {
        sink.writeln();
        _writeIndent(sink, level);
      }
      switch (node.type) {
        case VdomNodeType.element:
          if (node is VdomElement) {
            sink.write('<${node.tag}');
            _writeAttributes(sink, node.attributes, node.classes, node.styles);
            if (node.children != null && node.children!.isNotEmpty) {
              sink.write('>');
              _writeTo(sink, node.children, level: level + 1);
              if (_hasIndent) {
                sink.writeln();
                _writeIndent(sink, level);
              }
              sink.write('</${node.tag}>');
            } else {
              sink.write(' />');
            }
          }
          break;
        case VdomNodeType.text:
          if (node is VdomText) {
            sink.write(_textEscaper.convert(node.value));
          }
          break;
      }
    }
  }

  void _writeIndent(StringSink sink, int times) {
    if (_hasIndent) {
      for (var i = 0; i < times; i++) {
        sink.write(indent);
      }
    }
  }

  void _writeAttributes(
    StringSink sink,
    Map<String, String>? attrs,
    Iterable<String>? classes,
    Map<String, String>? styles,
  ) {
    if (attrs != null && attrs.containsKey('id')) {
      sink.write(' id="${_attrEscaper.convert(attrs['id']!)}"');
    }

    String? classValue;
    if (classes != null) {
      classValue = classes.join(' ');
    } else if (attrs != null && attrs.containsKey('class')) {
      classValue = attrs['class'];
    }
    if (classValue != null) {
      sink.write(' class="${_attrEscaper.convert(classValue)}"');
    }

    String? styleValue;
    if (styles != null) {
      final list = styles.keys.map((key) => '$key: ${styles[key]}').toList();
      list.sort();
      styleValue = list.join('; ');
    } else if (attrs != null && attrs.containsKey('style')) {
      styleValue = attrs['style'];
    }
    if (styleValue != null) {
      sink.write(' style="${_attrEscaper.convert(styleValue)}"');
    }

    if (attrs != null) {
      final keys = attrs.keys
          .where((s) => s != 'id' && s != 'class' && s != 'style')
          .toList();
      keys.sort();
      for (final key in keys) {
        final value = attrs[key];
        if (value != null) {
          sink.write(' $key="${_attrEscaper.convert(attrs[key]!)}"');
        }
      }
    }
  }
}

class _HtmlMarkupView implements View {
  @override
  Future invalidate() async {
    // no-op
  }

  @override
  R track<R>(R Function() action) => action();

  @override
  R escape<R>(R Function() action) => action();

  @override
  Future dispose() async {
    // no-op
  }

  @override
  void update() {
    throw UnimplementedError();
  }
}
