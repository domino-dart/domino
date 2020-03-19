import 'dart:io';

import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';
import 'package:path/path.dart' as p;

class ParsedSource {
  final List<Element> templates;
  final String path;

  ParsedSource(this.templates, [this.path]);
}

ParsedSource parseFileToCanonical(String path) {
  // Direct parent directory's name
  final defNs = p.basename(p.dirname(path));
  final defaultTemplate = p.basenameWithoutExtension(path);
  final htmlSource = File(path).readAsStringSync();
  final templates = parseToCanonical(htmlSource,
          defTemp: defaultTemplate, defaultNamespace: defNs)
      .templates;
  return ParsedSource(templates, path);
}

ParsedSource parseToCanonical(String html,
    {String defTemp, String defaultNamespace = 'd'}) {
  final templates = <Element>[];

  final root = html_parser.parseFragment(html);

  // Simple definition to d-template transformation
  for (final element in root.children) {
    if (element.localName == 'd-template') continue;
    final localName = element.localName;
    final parts = localName.split('.');
    final methodName = parts.last;
    String namespace = parts.sublist(0, parts.length - 1).join('.');
    if (namespace == '') {
      namespace = defaultNamespace;
    }
    final template = Element.tag('d-template');
    template.attributes.addAll(element.attributes);
    template.nodes.addAll(element.nodes);
    template.attributes['*'] = methodName;
    template.attributes['d-namespace'] = namespace;
    templates.add(template);
  }

  templates.addAll(root.children.where((e) => e.localName == 'd-template'));

  for (final templateElem in templates) {
    // Add slot variables
    final slotNames = _collectSlots(templateElem);
    for (final name in slotNames) {
      final varSlot = Element.tag('d-template-var')
        ..attributes['name'] = name
        ..attributes['type'] = 'SlotFn'
        ..attributes['library'] = 'package:domino/src/experimental/idom.dart';
      templateElem.append(varSlot);
    }

    templateElem.attributes['*'] =
        _dartName(templateElem.attributes['*'], prefix: 'render');

    for (final key in templateElem.attributes.keys.toList()) {
      final attr = key.toString();
      if (!attr.contains('-') && !attr.contains('*')) {
        final value = templateElem.attributes.remove(key);
        final parts = value.split('#').map((s) => s.trim()).toList();
        var library = 'dart:core';
        if (parts.length > 1 &&
            (parts[0].contains(':') || parts[0].endsWith('.dart'))) {
          library = parts.removeAt(0);
        }
        final type = parts.removeAt(0);
        bool required = false;
        if (parts.contains('required')) {
          parts.remove('required');
          required = true;
        }
        String defaultValue;
        final defaultAttr = parts.firstWhere((p) => p.startsWith('default:'),
            orElse: () => null);
        if (defaultAttr != null) {
          parts.remove(defaultAttr);
          defaultValue = defaultAttr.substring(8).trim();
        }
        String documentation;
        if (parts.isNotEmpty) {
          documentation = parts.removeAt(0);
        }
        final varElem = Element.tag('d-template-var')
          ..attributes['name'] = _dartName(attr, prefix: '')
          ..attributes['library'] = library
          ..attributes['type'] = type;
        if (required) {
          varElem.attributes['required'] = 'true';
        }
        if (defaultValue != null) {
          varElem.attributes['default'] = defaultValue;
        }
        if (documentation != null) {
          varElem.attributes['doc'] = documentation;
        }
        templateElem.nodes.insert(0, varElem);
      }
    }

    _rewriteAll(templateElem.nodes);
  }

  return ParsedSource(templates);
}

List<String> _collectSlots(Element elem) {
  final slotNames = <String>[];
  if (elem.localName == 'd-slot') {
    final name = _dartName(elem.attributes['*'] ?? '', prefix: 'slot');
    elem.attributes['*'] = name;
    slotNames.add(name);
  }
  for (final child in elem.children) {
    slotNames.addAll(_collectSlots(child));
  }
  return slotNames;
}

void _pullAttr(Element node, String tag, {Iterable<String> alternatives}) {
  final attrs = [tag, if (alternatives != null) ...alternatives]
      .where((s) => s != null)
      .toList();
  final first = attrs.firstWhere((a) => node.attributes.containsKey(a),
      orElse: () => null);
  if (first != null) {
    final v = node.attributes.remove(first);
    final elem = Element.tag(tag);
    if (v.isNotEmpty) {
      elem.attributes['*'] = v;
    }
    node.replaceWith(elem);
    elem.append(node);
  }
}

void _rewriteAll(NodeList list) {
  for (int i = 0; i < list.length; i++) {
    Node old;
    while (old != list[i]) {
      old = list[i];
      _rewrite(old);
    }
  }
}

void _rewrite(Node node) {
  if (node is Element) {
    _pullAttr(node, 'd-for', alternatives: ['*for']);
    _pullAttr(node, 'd-if', alternatives: ['*if']);
    _pullAttr(node, 'd-else-if', alternatives: ['*else-if', '*elseif']);
    _pullAttr(node, 'd-else', alternatives: ['*else']);

    for (final key in node.attributes.keys.toList()) {
      if (key is String && key.startsWith('#')) {
        node.attributes.remove(key);
        node.attributes['d-key'] = '\'${key.substring(1)}\'';
      }
    }

    // Short d-call
    if (node.localName.contains('.') ||
        (node.localName.contains('-') && !node.localName.startsWith('d-'))) {
      // Translate to d-call
      final dot = node.localName.lastIndexOf('.');
      final method = node.localName.substring(dot + 1);
      final namespace = dot >= 0 ? node.localName.substring(0, dot) : 'd';
      final dcall = Element.tag('d-call')
        ..attributes = node.attributes
        ..attributes['d-method'] = _dartName(method, prefix: 'render')
        ..attributes['d-namespace'] = namespace;
      node.reparentChildren(dcall);
      node.replaceWith(dcall);
      _rewrite(dcall);
    }

    if (node.localName == 'd-call') {
      final expr = node.attributes.remove('*');
      if (expr != null) {
        final parts = expr.split('#').map((p) => p.trim()).toList();

        if (parts.first.endsWith('.dart') || parts.first.endsWith('.html')) {
          node.attributes['d-library'] ??= parts.removeAt(0);
        }
        if (parts.isNotEmpty) {
          final method = parts.removeAt(0);
          node.attributes['d-method'] ??= method;
        }
      }
      final libValue = node.attributes['d-library'];
      if (libValue != null && libValue.endsWith('.html')) {
        node.attributes['d-library'] = libValue.replaceAll('.html', '.g.dart');
      }
      final removeNodes = <Node>[];
      final defSlotNodes = <Node>[];
      for (final chd in node.nodes) {
        if (chd is Element &&
            !['d-call-slot', 'd-call-var'].contains(chd.localName)) {
          defSlotNodes.add(chd);
        } else if (chd is Text && chd.text.trim() != '') {
          defSlotNodes.add(chd);
        } else if (chd is Comment) {
          removeNodes.add(chd);
        }
      }
      removeNodes.forEach((nd) => node.parent.insertBefore(nd, node));
      removeNodes.addAll(defSlotNodes);
      node.nodes.removeWhere(removeNodes.contains);
      if (defSlotNodes.isNotEmpty) {
        // add default node if it does not have any, and has real node
        final defSlot = Element.tag('d-call-slot')
          ..attributes['*'] = 'slot'
          ..nodes.addAll(defSlotNodes);
        node.append(defSlot);
      }
      for (final key in node.attributes.keys.toList()) {
        final attr = key.toString();
        if (!attr.contains('-') && !attr.contains('*')) {
          final varname = attr;
          final value = node.attributes[attr];
          final dCallVar = Element.tag('d-call-var')
            ..attributes['*'] = _dartName(varname)
            ..attributes['d-value'] = value;
          node.append(dCallVar);
          node.attributes.remove(attr);
        }
      }
    }

    if (node.localName == 'd-slot') {
      node.attributes['*'] ??= 'slot';
    }
    if (node.localName == 'd-call-slot') {
      node.attributes['*'] ??= 'slot';
    }

    _rewriteAll(node.nodes);
  }
}

String _dartName(String htmlName, {String prefix = ''}) {
  return htmlName.startsWith('d:')
      ? htmlName.substring(2)
      : (prefix +
              htmlName
                  .toLowerCase()
                  .replaceAllMapped(
                      RegExp('(^|-)(\\S)'), (m) => m.group(2).toUpperCase())
                  .replaceAll('-', '_'))
          .replaceFirstMapped(
              RegExp('.'), (firstCh) => firstCh.group(0).toLowerCase());
}
