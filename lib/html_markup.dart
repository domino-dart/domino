import 'dart:async';
import 'dart:convert';

import 'domino.dart';
import 'src/build_context.dart';
import 'src/vdom.dart';

HtmlEscape _attrEscaper = new HtmlEscape(HtmlEscapeMode.attribute);
HtmlEscape _textEscaper = new HtmlEscape(HtmlEscapeMode.element);

/// Builds HTML markup based on the hierarchy of [Component]s and [Element]s.
/// Intended mostly for testing, but it could work as a server-side renderer too.
class HtmlMarkupBuilder {
  final String indent;
  final bool _hasIndent;
  HtmlMarkupBuilder({this.indent})
      : _hasIndent = indent != null && indent.isNotEmpty;

  String convert(dynamic item) {
    final buffer = new StringBuffer();
    final nodes = new BuildContextImpl(new _HtmlMarkupView()).buildNodes(item);
    _writeTo(buffer, nodes);
    return buffer.toString().trim();
  }

  void _writeTo(StringSink sink, List<VdomNode> nodes, {int level: 0}) {
    if (nodes == null) return;
    for (VdomNode node in nodes) {
      if (_hasIndent) {
        sink.writeln();
        _writeIndent(sink, level);
      }
      if (node is VdomText) {
        sink.write(_textEscaper.convert(node.value ?? ''));
      } else if (node is VdomElement) {
        sink.write('<${node.tag}');
        _writeAttributes(sink, node.attributes, node.classes, node.styles);
        if (node.children != null && node.children.isNotEmpty) {
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
    }
  }

  void _writeIndent(StringSink sink, int times) {
    if (_hasIndent) {
      for (int i = 0; i < times; i++) {
        sink.write(indent);
      }
    }
  }

  void _writeAttributes(
    StringSink sink,
    Map<String, String> attrs,
    Iterable<String> classes,
    Map<String, String> styles,
  ) {
    if (attrs != null && attrs.containsKey('id')) {
      sink.write(' id="${_attrEscaper.convert(attrs['id'])}"');
    }

    String classValue;
    if (classes != null) {
      classValue = classes.join(' ');
    } else if (attrs != null && attrs.containsKey('class')) {
      classValue = attrs['class'];
    }
    if (classValue != null) {
      sink.write(' class="${_attrEscaper.convert(classValue)}"');
    }

    String styleValue;
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
      List<String> keys = attrs.keys
          .where((s) => s != 'id' && s != 'class' && s != 'style')
          .toList();
      keys.sort();
      for (String key in keys) {
        final value = attrs[key];
        if (value != null) {
          sink.write(' $key="${_attrEscaper.convert(attrs[key])}"');
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
}
