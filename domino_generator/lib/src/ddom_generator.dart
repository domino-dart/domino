import 'package:code_builder/code_builder.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:dart_style/dart_style.dart';
import 'package:xml/xml.dart';

import 'canonical.dart';

class GeneratedSource {
  final String dartFileContent;
  final String sassFileContent;

  GeneratedSource({
    required this.dartFileContent,
    required this.sassFileContent,
  });
}

final _ddomDart = 'package:domino/src/experimental/ddom.dart';
final _required = refer('required', 'package:meta/meta.dart');

GeneratedSource generateSource(String htmlContent) {
  final ps = parseToCanonical(htmlContent);
  final library = Library((lib) {
    for (final template in ps.templates) {
      final vars = template
          .findElements('template-var', namespace: dominoNs)
          .map((ve) => TemplateVar.fromElem(ve))
          .toList();

      lib.body.add(Class((clazz) {
        final methodName =
            template.getAttribute('method-name', namespace: dominoNs)!;
        clazz.name = methodName.replaceFirst('render', '');
        clazz.extend = refer('DComponent', _ddomDart);
        clazz.fields.addAll(vars.map((v) => Field((f) {
              f.name = v.name;
              f.type = refer(v.type!, v.library);
              if (v.documentation != null) {
                f.docs.add('  /// ${v.documentation}');
              }
            })));
        clazz.fields.add(Field((f) {
          f.name = '_nodes';
          f.type = TypeReference((b) => b
            ..symbol = 'List'
            ..types.add(refer('DNode', _ddomDart)));
        }));
        clazz.constructors.add(Constructor((c) {
          c.optionalParameters.addAll(vars.map((v) => Parameter((p) {
                p.name = v.name!;
                p.toThis = true;
                p.named = true;
                if (v.required) p.annotations.add(_required);
                if (v.defaultValue != null) p.defaultTo = Code(v.defaultValue!);
              })));
        }));
        clazz.methods.add(Method((m) {
          m
            ..name = 'renderNodes'
            ..annotations.add(refer('override'))
            ..returns = TypeReference((b) => b
              ..symbol = 'Iterable'
              ..types.add(refer('DNode', _ddomDart)))
            ..body = Code.scope((allocator) {
              final items = _render(allocator, template.children);
              return 'return _nodes ??= [${items.where((v) => v != null && v.isNotEmpty).join(',')}];';
            });
        }));
      }));
    }
  });

  final emitter = DartEmitter(allocator: Allocator.simplePrefixing());
  return GeneratedSource(
    dartFileContent: DartFormatter().format('${library.accept(emitter)}'),
    sassFileContent: '',
  );
}

Iterable<String> _render(
    String Function(Reference) allocator, Iterable<XmlNode> nodes) sync* {
  final dnodeQN = allocator(refer('DNode', _ddomDart));
  for (final node in nodes) {
    if (node is XmlElement) {
      if (_isDominoElem(node, 'template-var')) continue;
      if (_isDominoElem(node, 'class')) continue;
      if (_isDominoElem(node, 'else-if')) continue;
      if (_isDominoElem(node, 'else')) continue;

      if (_isDominoElem(node, 'if')) {
        final difc = allocator(refer('DIfComponent', _ddomDart));
        final dif = allocator(refer('DIfExpr', _ddomDart));
        final exprs = <String>[];
        void addExpr(XmlElement elem) {
          final cond = elem.getDominoAttr('expr');
          final children = _render(allocator, elem.children).toList();
          exprs.add(
              '$dif(() => $cond, () => <$dnodeQN>[${children.join(', ')}],)');
        }

        addExpr(node);
        var next = node.nextElementSibling;
        while (next != null && _isDominoElem(next, 'else-if')) {
          addExpr(next);
          next = next.nextElementSibling;
        }
        var orElse = '';
        if (next != null && _isDominoElem(next, 'else')) {
          final children = _render(allocator, next.children).toList();
          orElse = ', orElse: () => <$dnodeQN>[${children.join(', ')}],';
        }

        yield '$difc([${exprs.join(', ')}]$orElse)';
        continue;
      }

      final children = _render(allocator, node.children).toList();
      if (_isDominoElem(node, 'for')) {
        final expr = node.getDominoAttr('expr')!.split(' in ');
        final dfc = allocator(refer('DForComponent', _ddomDart));
        final dfe = allocator(refer('DForExpr', _ddomDart));
        yield '$dfc(() => ${expr.last}.map((${expr.first}) => $dfe(${expr.first}, () => <$dnodeQN>[${children.join(', ')}])))';
        continue;
      }

      // TODO: final classElems = elem.findElements('class', namespace: dominoNs).toList();
      // TODO: styles
      // TODO: attrs

      final childrenAttr =
          children.isEmpty ? '' : ', children: [${children.join(', ')}]';
      final delemQN = allocator(refer('DElem', _ddomDart));
      yield '$delemQN(\'${node.name.local}\'$childrenAttr)';
      continue;
    }
    if (node is XmlText) {
      final dtextQN = allocator(refer('DText', _ddomDart));
      final nodeText = node.text;
      final trimmedNodeText = nodeText.trim();
      if (trimmedNodeText.isEmpty) continue;
      final ipt = _interpolateText(node.text);
      if (ipt == trimmedNodeText) {
        yield '$dtextQN(\'$ipt\')';
      } else {
        yield '$dtextQN.fn(() => \'$ipt\')';
      }
      continue;
    }
    throw UnimplementedError('Unknown: $node');
  }
}

bool _isDominoElem(XmlElement elem, String tag) =>
    elem.name.namespaceUri == dominoNs && elem.name.local == tag;

// Matches strings for interpolation
final _expr = RegExp('{{(.+?)}}');

// Returns a list where each element is either text
// or a string for interpolation
List<String> _interpolateTextParts(String value) {
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
    final e = m.group(1)!.trim();
    parts.add('\${$e}');
    pos = m.end;
  }
  if (pos < value.length) {
    addText(value.substring(pos));
  }
  return parts;
}

String _interpolateText(String value) {
  return _interpolateTextParts(value).join();
}


class TemplateVar {
  String? library;
  String? type;
  String? name;
  String? defaultValue;
  String? documentation;
  bool required = false;

  TemplateVar.fromElem(XmlElement ve) {
    library = ve.getDominoAttr('library');
    type = ve.getDominoAttr('type');
    name = ve.getDominoAttr('name');
    defaultValue = ve.getDominoAttr('default');
    documentation = ve.getDominoAttr('doc');
    required = ve.getDominoAttr('required') == 'true';
  }
}

extension XmlElementExt on XmlElement {
  XmlElement? get nextElementSibling {
    final list = parent!.children;
    final index = list.indexOf(this);
    return list
        .skip(index + 1)
        .firstWhereOrNull((n) => n is XmlElement) as XmlElement?;
  }
}
