import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:html/dom.dart';

import 'canonical.dart';
import 'template_registry.dart';

class ComponentGenerator {
  final _imports = <String, _Import>{};
  final _sb = StringBuffer();
  final _registry = TemplateRegistry();

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

  void compileDirectory(String path, {bool recursive = true}) {
    _registry.registerDirectory(path, recursive: recursive);
    for(final file in Directory(path).listSync(recursive: recursive)) {
      if(file is File && file.path.endsWith('.html')) {
        final genPath = file.path.replaceAll('.html', '.g.dart');
        final htmlSource = file.readAsStringSync();
        _registry.basePath = file.parent.path;
        final dartSource = generateSource(htmlSource);
        File(genPath).writeAsStringSync(dartSource);
      }
    }
  }

  String generateSource(String sourceHtml) {
    _reset();
    final parsed = parseToCanonical(sourceHtml);
    final idomcAlias = _importAlias(
        'package:domino/src/experimental/idom.dart', ['DomContext']);

    for (final template in parsed.templates) {
      final name = template.attributes['*'].replaceAll('-', '_') ?? 'render';

      final topLevelObjects = <String>[];

      _sb.writeln('void $name($idomcAlias.DomContext \$d');
      final defaultInits = <String>[];
      for (final ve in template.querySelectorAll('d-template-var').toList()) {
        ve.remove();
        final library = ve.attributes['library'];
        final type = ve.attributes['type'];
        final name = ve.attributes['name'];
        final defaultValue = ve.attributes['default'];
        final documentation = ve.attributes['doc'];
        final required = ve.attributes['required'] == 'true';
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
    return '${_renderImports()}\n$_sb';
    return DartFormatter().format('${_renderImports()}\n$_sb');
  }

  void _render(Stack stack, List<Node> nodes) {
    for (final node in nodes) {
      if (node is Element) {
        if (node.localName == 'd-for') {
          final expr = node.attributes['*'].split(' in ');
          final object = expr[0].trim();
          final ns = Stack(parent: stack, objects: [object]);
          _sb.writeln(
              'for (final $object in ${stack.canonicalize(expr[1].trim())}) {');
          _render(ns, node.nodes);
          _sb.writeln('}');
        } else if ((node.localName == 'd-if')) {
          final cond = node.attributes['*'];
          _sb.writeln('if (${stack.canonicalize(cond)}) {');
          _render(stack, node.nodes);
          _sb.writeln('}');
        } else if (node.localName == 'd-else-if') {
          final cond = node.attributes['*'];
          _sb.writeln('else if (${stack.canonicalize(cond)}) {');
          _render(stack, node.nodes);
          _sb.writeln('}');
        } else if (node.localName == 'd-else') {
          _sb.writeln('else {');
          _render(stack, node.nodes);
          _sb.writeln('}');
        } else if (node.localName == 'd-call') {
          _renderCall(stack, node);
        } else if (node.localName == 'd-call-slot') {
          _renderCallSlot(stack, node);
        } else if (node.localName == 'd-slot') {
          _renderSlot(stack, node);
        } else {
          _renderElem(stack, node);
        }
      } else if (node is Text) {
        if (node.text.trim().isEmpty) continue;
        _sb.writeln('    \$d.text(\'${_interpolateText(stack, node.text)}\');');
      } else {
        throw UnsupportedError('Node: ${node.runtimeType}');
      }
    }
  }

  void _renderElem(Stack stack, Element elem) {
    final key = elem.attributes.remove('d-key');
    final openParams = <String>[];
    if (key != null) {
      openParams.add(', key: $key');
    }

    _sb.writeln('    \$d.open(\'${elem.localName}\' ${openParams.join()});');
    for (final attr in elem.attributes.keys) {
      _sb.writeln(
          '    \$d.attr(\'$attr\', \'${_interpolateText(stack, elem.attributes[attr])}\');');
    }
    _render(stack, elem.nodes);
    _sb.writeln('    \$d.close();');
  }

  void _renderCall(Stack stack, Element elem) {
    final library = elem.attributes.remove('d-library');
    final method = elem.attributes.remove('d-method') ?? '';
    final namespace = elem.attributes.remove('d-namespace') ?? '';
    final params = <String>[];
    for (final attrKey in elem.attributes.keys) {
      final name = attrKey.toString();
      final expr = elem.attributes[attrKey];
      params.add(', $name: $expr');
    }
    final alias = _importAlias(
        library ??
            _registry.resolveNamePath('$namespace:$method') ??
            _registry.resolveNamePath(method),
        [method]);
    if (alias != null) {
      _sb.write(alias == null ? '' : '$alias.');
    }


    _render(stack, elem.nodes);

    _sb.write('$method(\$d');
    _sb.write(params.join());
    _sb.writeln(', \$dSlots: \$dSlots');
    _sb.writeln(');');
  }

  String _interpolateText(Stack stack, String value) {
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
    return parts.join();
  }

  void _renderCallSlot(Stack stack, Element elem) {
    final method = elem.attributes.remove('d-method');
    _sb.writeln('    if(\$dSlots[$method] != null) \$dSlots[$method](\$d);');
  }

  void _renderSlot(Stack stack, Element elem) {
    final aliasdc = _importAlias(
      'package:domino/src/experimental/idom.dart', ['DomContext']);
    _sb.writeln('\$dSlots[\'${elem.attributes['d-method']}\']=');
    _sb.writeln('    ($aliasdc.DomContext \$d){');

    _render(stack, elem.nodes);

    _sb.writeln('};');
  }
}

final _expr = RegExp('{{(.+?)}}');

class Stack {
  final Stack _parent;
  final Set<String> _objects;
  final bool _emitWhitespaces;

  Stack({Stack parent, bool emitWhitespaces, Iterable<String> objects})
      : _parent = parent,
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
