import 'dart:convert';

import 'ddom.dart';

final _attrEscaper = HtmlEscape(HtmlEscapeMode.attribute);
final _textEscaper = HtmlEscape(HtmlEscapeMode.element);

/// Builds HTML markup based on the hierarchy of [DNode]s.
/// Intended mostly for testing and server-side rendering.
class HtmlBuilderVisitor extends DVisitor {
  final String indent;
  final bool _hasIndent;
  final _sink = StringBuffer();
  int _indentLevel = 0;
  int _maxIndentLevel = 0;

  HtmlBuilderVisitor({this.indent})
      : _hasIndent = indent != null && indent.isNotEmpty;

  String convert(DNode node) {
    _sink.clear();
    _indentLevel = 0;
    visitNode(node);
    return _sink.toString();
  }

  @override
  void visitElem(DElem node) {
    _writeIndent();

    _sink.write('<${node.tag}');
    _writeAttributes(
        _sink, node.attrs?.values, node.classes?.asList, node.styles?.values);
    if (node.hasChildren) {
      _sink.write('>');
      _indentLevel++;
      node.children.forEach(visitNode);
      _indentLevel--;
      _writeIndent();
      _sink.write('</${node.tag}>');
    } else {
      _sink.write(' />');
    }
  }

  @override
  void visitInnerHtml(DInnerHtml node) {
    _sink.write(_textEscaper.convert(node.value ?? ''));
  }

  @override
  void visitText(DText node) {
    _sink.write(node.value);
  }

  void _writeIndent() {
    if (_hasIndent) {
      if (_maxIndentLevel > _indentLevel) {
        _sink.writeln();
        _maxIndentLevel = _indentLevel;
      }
      for (var i = 0; i < _indentLevel; i++) {
        _sink.write(indent);
      }
      if (_maxIndentLevel < _indentLevel) {
        _maxIndentLevel = _indentLevel;
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
      final keys = attrs.keys
          .where((s) => s != 'id' && s != 'class' && s != 'style')
          .toList();
      keys.sort();
      for (final key in keys) {
        final value = attrs[key];
        if (value != null) {
          sink.write(' $key="${_attrEscaper.convert(attrs[key])}"');
        }
      }
    }
  }
}
