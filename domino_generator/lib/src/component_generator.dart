import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:html/dom.dart';

import 'canonical.dart';
import 'template_registry.dart';

class ComponentGenerator {
  final _imports = <String, _Import>{};
  final _sb = StringBuffer();
  final TemplateRegistry registry;
  final String baseFile;

  ComponentGenerator({this.registry, this.baseFile});

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

      // SCSS class name
      final scssName =
          ('${template.attributes['d-namespace']}_$name').replaceAll('.', '_');

      _render(
          Stack(objects: topLevelObjects, clazzName: scssName), template.nodes);

      _sb.writeln('}');
    }
    String text;
    try {
      text = DartFormatter().format('${_renderImports()}\n$_sb');
    } on FormatterException catch (e) {
      print(e);
      text = '${_renderImports()}\n$_sb';
    }
    return text;
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
        } else if (node.localName == 'd-slot') {
          _renderSlot(stack, node);
        } else {
          _renderElem(stack, node);
        }
      } else if (node is Text) {
        if (node.text.trim().isEmpty) continue;
        _sb.writeln('    \$d.text(\'${_interpolateText(stack, node.text)}\');');
      } else if (node is Comment) {
        _sb.writeln('/*${node.text}*/');
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
    // write clazz
    _sb.writeln('    \$d.clazz(\'${stack.clazzName}\');\n');
    _render(stack, elem.nodes);
    _sb.writeln('    \$d.close();');
  }

  void _renderCall(Stack stack, Element elem) {
    final library = elem.attributes.remove('d-library');
    final method = elem.attributes.remove('d-method') ?? '';
    final namespace = elem.attributes.remove('d-namespace') ?? '';
    final alias = _importAlias(
        library ??
            registry?.resolveNamePath('$namespace.$method',
                basePath: baseFile) ??
            registry?.resolveNamePath(method, basePath: baseFile),
        [method]);
    if (alias != null) {
      _sb.write(alias == null ? '' : '$alias.');
    }

    _sb.write('$method(\$d');

    for (final ch in elem.children) {
      if (ch.localName == 'd-call-var') {
        _sb.write(', ${ch.attributes['*']}:${ch.attributes['d-value']}');
      }
      if (ch.localName == 'd-call-slot') {
        final idomcAlias = _importAlias(
            'package:domino/src/experimental/idom.dart', ['DomContext']);
        _sb.writeln(', ${ch.attributes['*']}: ($idomcAlias.DomContext \$d){');
        _render(stack, ch.nodes);
        _sb.writeln('}');
      }
    }

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

  void _renderSlot(Stack stack, Element elem) {
    final method = elem.attributes.remove('*');
    _sb.writeln('$method(\$d);');
  }

  String generateScss(ParsedSource parsedSource) {
    final data = StringBuffer();
    for(final template in parsedSource.templates) {
      // copied from generateParsedSource
      final name = template.attributes['*'].replaceAll('-', '_') ?? 'render';
      final scssName =
      ('${template.attributes['d-namespace']}_$name').replaceAll('.', '_');
      final styles = template.getElementsByTagName('d-style');
      for(final elem in styles ) {
        data.writeln('.$scssName { ${elem.innerHtml} }');
      }
    }
    return data.toString();
  }
}

final _expr = RegExp('{{(.+?)}}');

class Stack {
  final Stack _parent;
  final Set<String> _objects;
  final bool _emitWhitespaces;
  final String _clazzName;

  Stack(
      {Stack parent,
      bool emitWhitespaces,
      Iterable<String> objects,
      String clazzName})
      : _parent = parent,
        _objects = objects?.toSet() ?? <String>{},
        _emitWhitespaces = emitWhitespaces,
        _clazzName = clazzName;

  bool get emitWhitespaces =>
      _emitWhitespaces ?? _parent?.emitWhitespaces ?? false;

  String get clazzName => _clazzName ?? _parent?.clazzName ?? '';

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

compileDirectory(String path,
    {bool recursive = true, bool debugParse = false}) {
  final psList = <ParsedSource>[];
  for (final file in Directory(path).listSync(recursive: recursive)) {
    if (file.path.endsWith('.html') && !file.path.endsWith('.g.html')) {
      final ps = parseFileToCanonical(file.path);
      psList.add(ps);
      if (debugParse) {
        final genPath = ps.path.replaceAll('.html', '.g.html');
        File(genPath).writeAsStringSync(
            ps.templates.map((e) => e.outerHtml).join('\n\n'));
      }
    }
  }
  final reg = TemplateRegistry();
  reg.registerAll(psList);
  for (final ps in psList) {
    final cg = ComponentGenerator(registry: reg, baseFile: ps.path);
    final genSource = cg.generateParsedSource(ps);
    final genPath = ps.path.replaceAll('.html', '.g.dart');
    File(genPath).writeAsStringSync(genSource);

    final genScss = cg.generateScss(ps);
    final genScssPath = ps.path.replaceAll('.html', '.scss');
    File(genScssPath).writeAsStringSync(genScss);
  }
}
