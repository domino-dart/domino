import 'dart:convert';

import 'package:crypto/crypto.dart' show sha256;
import 'package:dart_style/dart_style.dart';
import 'package:xml/xml.dart';

import 'canonical.dart';

class ComponentGenerator {
  final _imports = <String, _Import>{};
  final _sb = StringBuffer();
  final _texts = <_TextElem>[];

  void _reset() {
    _imports.clear();
    _sb.clear();
  }

  String _importAlias(String url, Iterable<String> types) {
    if (url == null || url == 'dart:core') return null;
    final imp =
        _imports.putIfAbsent(url, () => _Import(url, '_i${_imports.length}'));
    imp.show.addAll(types);
    return imp.alias;
  }

  String _renderImports() {
    final list = _imports.values.toList();
    list.sort((a, b) {
      if (a.url.startsWith('package:') && !b.url.startsWith('package:')) {
        return -1;
      }
      if (!a.url.startsWith('package:') && b.url.startsWith('package:')) {
        return 1;
      }
      return a.url.compareTo(b.url);
    });
    return list
        .map((i) =>
            'import \'${i.url}\' as ${i.alias} show ${(i.show.toList()..sort()).join(', ')};\n')
        .join();
  }

  String generateSource(String source) {
    return generateParsedSource(parseToCanonical(source));
  }

  String generateParsedSource(ParsedSource parsed) {
    _reset();
    final idomcAlias = _importAlias(
        'package:domino/src/experimental/idom.dart', ['DomContext']);

    for (final template in parsed.templates) {
      final name = template.getAttribute('method-name', namespace: dominoNs);

      final topLevelObjects = <String>[];

      _sb.writeln('void $name($idomcAlias.DomContext \$d');
      final defaultInits = <String>[];
      for (final ve in template
          .findElements('template-var', namespace: dominoNs)
          .toList()) {
        final library = ve.getDominoAttr('library');
        final type = ve.getDominoAttr('type');
        final name = ve.getDominoAttr('name');
        final defaultValue = ve.getDominoAttr('default');
        final documentation = ve.getDominoAttr('doc');
        final required = ve.getDominoAttr('required') == 'true';
        ve.parent.children.remove(ve);
        final alias = _importAlias(library, [type]);
        final aliasedType = alias == null ? type : '$alias.$type';
        if (topLevelObjects.isEmpty) {
          _sb.write(', {');
        }
        topLevelObjects.add(name);
        if (documentation != null) {
          _sb.write('\n/// $documentation\n');
        }
        if (required) {
          final metaAlias =
              _importAlias('package:meta/meta.dart', ['required']);
          _sb.write('@$metaAlias.required ');
        }
        _sb.write('$aliasedType $name,\n');
        if (defaultValue != null) {
          defaultInits.add('$name ??= $defaultValue;');
        }
      }
      if (topLevelObjects.isNotEmpty) {
        _sb.write('}');
      }
      _sb.writeln(') {');
      defaultInits.forEach(_sb.writeln);
      topLevelObjects.add('\$d');

      _render(Stack(objects: topLevelObjects), template.nodes);

      _sb.writeln('}');
    }

    _sb.writeln('const \$strings = {');
    final snames = <String>{};
    for(final te in _texts) {
      snames.add(te.name);
    }
    for(final sn in snames) {
      _sb.writeln('\'$sn\': {');
      final usedLangs = <String>{};
      for(final te in _texts.where((te) => te.name == sn)) {
        if(usedLangs.contains(te.lang)) continue;
        usedLangs.add(te.lang);
        _sb.writeln('\'_params${te.lang}\': r\'${te.params}\',');
        _sb.writeln('\'${te.lang}\': r\'${te.text}\',');
      }
      _sb.writeln('},');
    }
    _sb.writeln('};');
      
    String text;
    try {
      text = DartFormatter().format('${_renderImports()}\n$_sb');
    } on FormatterException catch (e) {
      print(e);
      text = '${_renderImports()}\n$_sb';
    }
    return text;
  }

  String _scssName(XmlElement style) {
    // hash of the content
    final hash =
        sha256.convert(utf8.encode(style.text)).toString().substring(0, 20);
    // TODO: include template name as part of the name
    // TODO: include parent element tag as part of the name
    return ['ds', hash].join('_');
  }

  void _render(Stack stack, Iterable<XmlNode> nodes) {
    for (final node in nodes) {
      if (node is XmlElement) {
        if (_isDominoElem(node, 'for')) {
          final expr = node.getDominoAttr('expr').split(' in ');
          final object = expr[0].trim();
          final ns = Stack(parent: stack, objects: [object]);
          _sb.writeln(
              'for (final $object in ${stack.canonicalize(expr[1].trim())}) {');
          _render(ns, node.nodes);
          _sb.writeln('}');
        } else if (_isDominoElem(node, 'if')) {
          final cond = node.getDominoAttr('expr');
          _sb.writeln('if (${stack.canonicalize(cond)}) {');
          _render(stack, node.nodes);
          _sb.writeln('}');
        } else if (_isDominoElem(node, 'else-if')) {
          final cond = node.getDominoAttr('expr');
          _sb.writeln('else if (${stack.canonicalize(cond)}) {');
          _render(stack, node.nodes);
          _sb.writeln('}');
        } else if (_isDominoElem(node, 'else')) {
          _sb.writeln('else {');
          _render(stack, node.nodes);
          _sb.writeln('}');
        } else if (_isDominoElem(node, 'call')) {
          _renderCall(stack, node);
        } else if (_isDominoElem(node, 'attr')) {
          _renderAttr(stack, node);
        } else if (_isDominoElem(node, 'class')) {
          _renderClass(stack, node);
        } else if (_isDominoElem(node, 'slot')) {
          _renderSlot(stack, node);
        } else if (_isDominoElem(node, 'style')) {
          _renderStyle(stack, node);
        } else {
          _renderElem(stack, node);
        }
      } else if (node is XmlText) {
        if (node.text.trim().isEmpty) continue;
        _renderText(stack, node);
      } else if (node is XmlComment) {
        _sb.writeln('/*${node.text}*/');
      } else if (node is XmlAttribute) {
        //
      } else {
        throw UnsupportedError('Node: ${node.runtimeType}');
      }
    }
  }

  static final _whitespace = RegExp(r'\s+');
  static final _word = RegExp(r'\w+');
  void _renderText(Stack stack, XmlText node) {
    final text = node.text.trim().replaceAll(_whitespace, ' ');
    if (text == '') return; // empty line
    final fnName = 'text_' +
        _word.allMatches(text).take(3).map((e) => e.group(0)).join('_') +
        '_' +
        sha256.convert(utf8.encode(text)).toString().substring(0, 8);

    final parts = _interpolateTextParts(stack, text);
    var cnt = 0;
    final argNames = StringBuffer();
    final newText = StringBuffer();
    final params = <String, String>{};
    for (final part in parts) {
      if (part.startsWith('\$')) {
        params['\$arg$cnt'] = part.substring(2, part.length-1);
        newText.write('\$arg$cnt');

        if(cnt > 0) argNames.write(',');
        argNames.write('\$arg$cnt');
        cnt++;
      } else {
        newText.write(part);
      }
    }
    final textelem = _TextElem(fnName, newText.toString(), params: params);
    _texts.add(textelem);

    // Functions need to be used for interpolation.
    _sb.writeln('{    String $fnName($argNames) => '
        '(\$strings[r\'$fnName\'].containsKey(\$d.globals[\'locale\'])'
        '? \$strings[r\'$fnName\'][\$d.globals[\'locale\']]'
        ': \$strings[r\'$fnName\'][\'\'])'
    );
    _sb.writeln('.toString()');
    params.forEach((key, value) {
      _sb.writeln('      .replaceAll(r\'$key\', $key.toString())');
    });
    _sb.writeln(';');

    // second is a call to the function with the real parameters
    _sb.writeln(
        '    \$d.text($fnName(${textelem.params.values.join(',')}));}');
  }

  void _renderElem(Stack stack, XmlElement elem) {
    final tag = elem.name.local == 'element'
        ? elem.getDominoAttr('tag')
        : elem.name.local;
    final key = elem.removeDominoAttr('key');
    final openParams = <String>[];
    if (key != null) {
      openParams.add(', key: $key');
    }

    _sb.writeln('    \$d.open(\'$tag\' ${openParams.join()});');
    for (final attr in elem.attributes) {
      if (attr.name.namespaceUri != null) continue;
      _sb.writeln(
          '    \$d.attr(\'${attr.name.local}\', \'${_interpolateText(stack, attr.value)}\');');
    }

    // d-var attributes
    for (final dattr
        in elem.attributes.where((attr) => attr.name.namespaceUri == null)) {
      if (dattr.name.local.startsWith('var-')) {
        final valname = dartName(dattr.name.local.split('-')[1]);
        _sb.writeln('\n    var $valname;');
      }
    }
    // 'd-' attributes
    for (final dattr in elem.attributes
        .where((attr) => attr.name.namespaceUri == dominoNs)) {
      final attr = dattr.name.local;
      // Single d:event-onclick=dartFunction
      if (attr.startsWith('event-on')) {
        final parts = attr.split('-');
        final eventName = parts[1].substring(2);
        _sb.writeln(
            '    \$d.event(\'$eventName\', fn: ${_interpolateText(stack, dattr.value)});');
      }
      if (attr.startsWith('event-list-')) {
        _sb.writeln('''
        for(final key in ${_interpolateText(stack, dattr.value)}.keys) {
            \$d.event(key, fn: ${_interpolateText(stack, dattr.value)}[key]);
        }
        ''');
      }

      if (attr.startsWith('bind-input-')) {
        final ba = attr.split('-').sublist(2).join('-'); // binded attribute
        final ex = dattr.value; // expression
        _sb.writeln('''{
          final elem = \$d.element;
          elem.$ba = $ex;
          \$d.event('input', fn: (event) {
             $ex = elem.$ba;
          });
          \$d.event('change', fn: (event) {
             $ex = elem.$ba;
          });
        }'''); // TODO: add some way to clean up reference
      }
    }

    _render(stack, elem.nodes);
    _sb.writeln('    \$d.close();');
  }

  void _renderCall(Stack stack, XmlElement elem) {
    final library = elem.removeDominoAttr('library');
    final method = elem.removeDominoAttr('method') ?? '';
    final alias = _importAlias(library, [method]);
    if (alias != null) {
      _sb.write(alias == null ? '' : '$alias.');
    }

    _sb.write('$method(\$d');

    for (final ch in elem.elements) {
      if (ch.name.local == 'call-var') {
        _sb.write(', ${ch.getDominoAttr('name')}:${ch.getDominoAttr('value')}');
      }
      if (ch.name.local == 'call-slot') {
        final idomcAlias = _importAlias(
            'package:domino/src/experimental/idom.dart', ['DomContext']);
        _sb.writeln(
            ', ${ch.getDominoAttr('name')}: ($idomcAlias.DomContext \$d) {');
        _render(stack, ch.nodes);
        _sb.writeln('}');
      }
    }

    _sb.writeln(');');
  }

  // Returns a list where each element is either text
  // or a string for interpolation
  List<String> _interpolateTextParts(Stack stack, String value) {
    final parts = <String>[];

    void addText(String v) {
      final x = v
          .replaceAll('\'', '\\\'')
          .replaceAll(r'$', r'\$')
          .replaceAll('\n', r'\n');
      if (x.isNotEmpty) {
        parts.add(x);
      }
    }

    final matches = _expr.allMatches(value);
    var pos = 0;
    for (final m in matches) {
      if (pos < m.start) {
        addText(value.substring(pos, m.start));
      }
      var e = m.group(1).trim();
      if (e != '\' \'') {
        e = stack.canonicalize(e);
      }
      parts.add('\${$e}');
      pos = m.end;
    }
    if (pos < value.length) {
      addText(value.substring(pos));
    }
    return parts;
  }

  String _interpolateText(Stack stack, String value) {
    return _interpolateTextParts(stack, value).join();
  }

  void _renderAttr(Stack stack, XmlElement elem) {
    final name = elem.getDominoAttr('name');
    final value = _interpolateText(stack, elem.getDominoAttr('value'));
    _sb.writeln('\$d.attr(\'$name\', $value);');
  }

  void _renderClass(Stack stack, XmlElement elem) {
    final nameAttr = elem.getDominoAttr('name');
    final name = _interpolateText(stack, nameAttr);
    final presentAttr = elem.getDominoAttr('present');
    final present =
        presentAttr == null ? '' : ', ${_interpolateText(stack, presentAttr)}';
    _sb.writeln('\$d.clazz(\'$name\'$present);');
  }

  void _renderSlot(Stack stack, XmlElement elem) {
    final method = elem.removeDominoAttr('name');
    _sb.writeln('if ($method != null) {$method(\$d);}');
  }

  void _renderStyle(Stack stack, XmlElement elem) {
    final cn = _scssName(elem);
    _sb.writeln('    \$d.clazz(\'$cn\');\n');
  }

  String generateScss(ParsedSource parsedSource) {
    final data = StringBuffer();
    for (final template in parsedSource.templates) {
      final styles = template.findAllElements('style', namespace: dominoNs);
      for (final elem in styles) {
        data.writeln('.${_scssName(elem)} {');
        final lines = elem.text.split('\n');
        var indent = 1;
        for (final line in lines) {
          final lt = line.trim();
          if (lt.isEmpty) continue;
          if (lt == '}') {
            data.write('  ' * (indent - 1));
          } else {
            data.write('  ' * indent);
          }
          data.writeln(lt);
          indent += line.split('{').length - line.split('}').length;
        }
        data.writeln('}');
      }
    }
    return data.toString();
  }
}

// Matches strings for interpolation
final _expr = RegExp('{{(.+?)}}');

class Stack {
  final Stack _parent;
  final Set<String> _objects;
  final bool _emitWhitespaces;

  Stack({
    Stack parent,
    bool emitWhitespaces,
    Iterable<String> objects,
  })  : _parent = parent,
        _objects = objects?.toSet() ?? <String>{},
        _emitWhitespaces = emitWhitespaces;

  bool get emitWhitespaces =>
      _emitWhitespaces ?? _parent?.emitWhitespaces ?? false;

  String canonicalize(String expr) {
    var s = this;
    while (s != null) {
      if (s._objects.any((o) => expr.contains(o))) {
        return expr;
      }
      s = s._parent;
    }
    throw Exception('Unknown expression: $expr');
  }
}

class _Import {
  final String url;
  final String alias;
  final show = <String>{};

  _Import(this.url, this.alias);
}

bool _isDominoElem(XmlElement elem, String tag) =>
    elem.name.namespaceUri == dominoNs && elem.name.local == tag;

class _TextElem {
  final String name;
  final Map<String, String> params;
  final String text;
  final String lang;
  _TextElem._(this.name, this.text, this.lang, this.params);
  factory _TextElem(String name, String text,
      {String lang, Map<String, String> params}) {
    return _TextElem._(name, text, lang ?? '', params ?? {});
  }
}
