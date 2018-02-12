import 'dart:convert';

import 'domino.dart';
import 'src/build_context.dart';

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
    final context = new _BuildContext(buffer);
    _writeTo(context, item);
    return buffer.toString().trim();
  }

  void _writeTo(_BuildContext context, item, {int level: 0}) {
    final nodes = flattenWithContext(context, item);
    if (nodes == null) return;
    for (Node node in nodes) {
      if (_hasIndent) {
        context._sink.writeln();
        _writeIndent(context._sink, level);
      }
      if (node is Text) {
        context._sink.write(_textEscaper.convert(node.text ?? ''));
      } else if (node is Element) {
        context._sink.write('<${node.tag}');
        _writeAttributes(context._sink, node.attrs, node.classes, node.styles);
        if (node.hasChildren) {
          context._sink.write('>');
          _writeTo(context, node.children, level: level + 1);
          if (_hasIndent) {
            context._sink.writeln();
            _writeIndent(context._sink, level);
          }
          context._sink.write('</${node.tag}>');
        } else {
          context._sink.write(' />');
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

class _BuildContext extends AncestorBuildContext {
  final StringSink _sink;
  _BuildContext(this._sink);
}
