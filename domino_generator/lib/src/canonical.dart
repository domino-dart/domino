import 'dart:io';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:path/path.dart' as p;
import 'package:xml/xml.dart';

final dominoNs = 'domino';

class ParsedSource {
  final List<XmlElement> templates;
  final String? path;

  ParsedSource(this.templates, [this.path]);
}

ParsedSource parseFileToCanonical(String path) {
  final defaultTemplate = p.basenameWithoutExtension(path);
  final htmlSource = File(path).readAsStringSync();
  final parsed = parseToCanonical(htmlSource, defTemp: defaultTemplate);
  return ParsedSource(parsed.templates, path);
}

ParsedSource parseToCanonical(String html, {String? defTemp}) {
  final templates = <XmlElement>[];

  final source = '<d:root xmlns:d="$dominoNs">\n$html\n</d:root>';
  final doc = parse(source);
  final root = doc.rootElement;

  // Simple definition to d-template transformation
  for (final element in root.elements.toList()) {
    if (element.name.namespaceUri == dominoNs) continue;
    final localName = element.name.local;
    final parts = localName.split('.');
    final methodName = parts.last;
    final template = XmlElement(XmlName('template', 'd'));
    element.replaceWith(template, moveChildren: true);
    template.setDominoAttr('name', methodName);
    template.attributes
        .addAll(element.attributes.map((a) => a.copy() as XmlAttribute));
  }

  templates.addAll(root.elements.where(
      (e) => e.name.local == 'template' && e.name.namespaceUri == dominoNs));

  for (final templateElem in templates) {
    // Add slot variables
    final slotNames = _collectSlots(templateElem);
    for (final name in slotNames) {
      final varSlot = XmlElement(XmlName('template-var', 'd'));
      templateElem.append(varSlot);
      varSlot
        ..setDominoAttr('name', name)
        ..setDominoAttr('type', 'SlotFn')
        ..setDominoAttr('library', 'package:domino/src/experimental/idom.dart');
    }

    templateElem.setDominoAttr(
      'method-name',
      dartName(templateElem.getDominoAttr('name')!, prefix: 'render'),
    );

    for (final attr in templateElem.attributes.toList()) {
      if (attr.name.namespaceUri == dominoNs) continue;
      if (attr.name.prefix == 'xmlns') continue;
      templateElem.removeAttribute(attr.name.local,
          namespace: attr.name.namespaceUri);
      final parts = attr.value.split('#').map((s) => s.trim()).toList();
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
      String? defaultValue;
      final defaultAttr =
          parts.firstWhereOrNull((p) => p.startsWith('default:'));
      if (defaultAttr != null) {
        parts.remove(defaultAttr);
        defaultValue = defaultAttr.substring(8).trim();
      }
      String? documentation;
      if (parts.isNotEmpty) {
        documentation = parts.removeAt(0);
      }
      final varElem = XmlElement(XmlName('template-var', 'd'));
      templateElem.append(varElem);
      varElem
        ..setDominoAttr('name', dartName(attr.name.local, prefix: ''))
        ..setDominoAttr('library', library)
        ..setDominoAttr('type', type);
      if (required) {
        varElem.setDominoAttr('required', 'true');
      }
      if (defaultValue != null) {
        varElem.setDominoAttr('default', defaultValue);
      }
      if (documentation != null) {
        varElem.setDominoAttr('doc', documentation);
      }
    }

    _rewriteAll(templateElem.children);
  }

  return ParsedSource(templates);
}

Iterable<String> _collectSlots(XmlElement elem) {
  return elem
      .findAllElements('slot', namespace: dominoNs)
      .map((e) => e.getDominoAttr('name') ?? 'slot')
      .toList();
}

void _pullAttr(XmlElement node, String tag, {Iterable<String>? alternatives}) {
  final attrs = [tag, if (alternatives != null) ...alternatives]
      .where((s) => s != null)
      .toList();
  for (final attr in attrs) {
    final first = node.attributes.firstWhereOrNull(
      (a) => a.name.local == attr && a.name.namespaceUri == dominoNs,
    );
    if (first != null) {
      node.attributes.remove(first);
      final elem = XmlElement(XmlName(tag, 'd'));
      node.injectInTree(elem);
      if (first.value.trim().isNotEmpty) {
        elem.setDominoAttr('expr', first.value);
      }
      return;
    }
  }
}

void _rewriteAll(List<XmlNode> list) {
  for (int i = 0; i < list.length; i++) {
    XmlNode? old;
    while (old != list[i]) {
      old = list[i];
      _rewrite(old);
    }
  }
}

void _rewrite(XmlNode node) {
  if (node is XmlElement) {
    _pullAttr(node, 'for');
    _pullAttr(node, 'if');
    _pullAttr(node, 'else-if', alternatives: ['elseif']);
    _pullAttr(node, 'else');

    // TODO: check if key shortcut can be re-added somehow

    // Short d-call
    if ((node.name.prefix == 'local') ||
        (node.name.namespaceUri != null &&
            node.name.namespaceUri != dominoNs)) {
      // Translate to d-call
      final namespace =
          node.name.prefix == 'local' ? null : node.name.namespaceUri;
      final import = namespace == null
          ? null
          : namespace.endsWith('.html')
              ? namespace.replaceFirst('.html', '.g.dart')
              : namespace;

      final dcall = XmlElement(XmlName('call', 'd'));
      node.replaceWith(dcall, moveChildren: true, moveAttributes: true);
      if (import != null) {
        dcall.setDominoAttr('library', import);
      }
      dcall.setDominoAttr(
          'method', dartName(node.name.local, prefix: 'render'));
      _rewrite(dcall);
    }

    if (node.name.local == 'call' && node.name.namespaceUri == dominoNs) {
      final expr = node.getDominoAttr('expr');
      if (expr != null) {
        node.removeAttribute('expr', namespace: dominoNs);
        final parts = expr.split('#').map((p) => p.trim()).toList();

        if (parts.first.endsWith('.dart') || parts.first.endsWith('.html')) {
          node.setDominoAttr('library', parts.removeAt(0));
        }
        if (parts.isNotEmpty) {
          final method = dartName(parts.removeAt(0), prefix: 'render');
          node.setDominoAttr('method', method);
        }
      }
      final libValue = node.getDominoAttr('library');
      if (libValue != null && libValue.endsWith('.html')) {
        node.setDominoAttr('library', libValue.replaceAll('.html', '.g.dart'));
      }
      final removeNodes = <XmlNode>[];
      final defSlotNodes = <XmlNode>[];
      for (final chd in node.nodes) {
        if (chd is XmlElement &&
            !['call-slot', 'call-var'].contains(chd.name.local)) {
          defSlotNodes.add(chd);
        } else if (chd is XmlText && chd.text.trim() != '') {
          defSlotNodes.add(chd);
        } else if (chd is XmlComment) {
          removeNodes.add(chd);
        }
      }
      removeNodes.addAll(defSlotNodes);
      node.children.removeWhere(removeNodes.contains);
      if (defSlotNodes.isNotEmpty) {
        // add default node if it does not have any, and has real node
        final defSlot = XmlElement(XmlName('call-slot', 'd'));
        node.append(defSlot);
        defSlot.setDominoAttr('name', 'slot');
        defSlot.children.addAll(defSlotNodes.map((e) => e.copy()));
      }

      for (final attr in node.attributes.toList()) {
        if (attr.name.namespaceUri != null) continue;
        final varname = dartName(attr.name.local);
        final value = attr.value;
        final dCallVar = XmlElement(XmlName('call-var', 'd'));
        node.append(dCallVar);
        dCallVar..setDominoAttr('name', varname)..setDominoAttr('value', value);
        node.attributes.remove(attr);
      }

      // Collect events
      final events = <String, String>{}; // name -> action map
      for (final attr in node.attributes.toList()) {
        if (attr.name.local.startsWith('event-on')) {
          final eventName = attr.name.local.split('-')[1].substring(2);
          events[eventName] = attr.value;
          node.attributes.remove(attr);
        }
      }
      if (events.isNotEmpty) {
        final eventCallTag = XmlElement(XmlName('call-var', 'd'));
        node.append(eventCallTag);
        eventCallTag
          ..setDominoAttr('name', 'events')
          ..setDominoAttr(
            'value',
            '{${events.entries.map((e) => '\'${e.key}\': ${e.value}').join(',')}}',
          );
      }
    }

    if (node.name.local == 'slot' && node.name.namespaceUri == dominoNs) {
      final name = node.getDominoAttr('name');
      node.setDominoAttr('name', name ?? 'slot');
    }
    if (node.name.local == 'call-slot' && node.name.namespaceUri == dominoNs) {
      final name = node.getDominoAttr('name');
      node.setDominoAttr('name', name ?? 'slot');
    }

    final classAttr = node.getAttribute('class');
    if (node.name.namespaceUri == null && classAttr != null) {
      var index = 0;
      classAttr
          .split(' ')
          .map((c) => c.trim())
          .where((c) => c.isNotEmpty)
          .forEach((c) {
        final elem = XmlElement(XmlName('class', 'd'));
        node.children.insert(index++, elem);
        elem.setDominoAttr('name', c);
      });
      node.removeAttribute('class');
    }

    _rewriteAll(node.children);
  }
}

// recognizes patters in the following order:
// - phrase with lowercase letters + numbers
// - phrase starting with a single uppercase letter continued by lowercase + numbers
// - phrase with uppercase letters + numbers
final _caseRegExp = RegExp(r'([a-z0-9]+)|([A-Z][a-z0-9]+)|([A-Z0-9]+)');

/// Returns the name of the Dart method or parameter to be used.
String dartName(String htmlName, {String prefix = ''}) {
  // escape for direct name setter
  if (htmlName.startsWith('d:')) {
    return htmlName.substring(2).trim();
  }

  final parts =
      _caseRegExp.allMatches(htmlName).map((e) => e.group(0)).toList();
  if (prefix != null && prefix.isNotEmpty && !parts.first!.startsWith(prefix)) {
    parts.insert(0, prefix);
  }
  final cased = parts
      .map((s) => s!.toLowerCase())
      .map((s) => s.substring(0, 1).toUpperCase() + s.substring(1))
      .join();
  return cased.substring(0, 1).toLowerCase() + cased.substring(1);
}

extension XmlElementExt on XmlElement {
  Iterable<XmlElement> get elements => children.whereType<XmlElement>();

  void replaceWith(
    XmlElement other, {
    bool moveAttributes = false,
    bool moveChildren = false,
  }) {
    final index = parent!.children.indexOf(this);
    parent!.children.replaceRange(index, index + 1, [other]);
    if (moveAttributes) {
      other.attributes.addAll(attributes.map((a) => a.copy() as XmlAttribute));
    }
    if (moveChildren) {
      other.children.addAll(children.map((c) => c.copy()));
    }
  }

  void injectInTree(XmlElement other) {
    final index = parent!.children.indexOf(this);
    parent!.children.replaceRange(index, index + 1, [other]);
    other.append(copy());
  }

  void insertBefore(XmlNode node, XmlNode refNode) {
    final index = children.indexOf(refNode);
    children.insert(index, node);
  }

  void append(XmlNode node) {
    children.add(node);
    if (!node.hasParent) {
      node.attachParent(this);
    }
  }

  String? getDominoAttr(String name) {
    return getAttribute(name, namespace: dominoNs);
  }

  void setDominoAttr(String name, String value) {
    setAttribute(name, value, namespace: dominoNs);
  }

  String? removeDominoAttr(String name) {
    final v = getDominoAttr(name);
    removeAttribute(name, namespace: dominoNs);
    return v;
  }
}
