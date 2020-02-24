import 'dart:convert';

import 'idom.dart';

final _attrEscaper = HtmlEscape(HtmlEscapeMode.attribute);
final _textEscaper = HtmlEscape(HtmlEscapeMode.element);

/// DomContext for rendering to HTML files using virtual nodes.
class ServerDomContext implements DomContext<_IdomElem, Function> {
  /// root element of the current context
  final _IdomElem _rootElem;
  /// path of the normal elements, not changed before closing call
  final _path = <_IdomElem>[];
  /// shadow path, attribute and node changes are added to its last element,
  /// and copied to the normal element after closing it
  final _shadowPath = <_IdomElem>[];
  /// stores the indexes of currently selected node in the _shadowPath
  final _indexes = <int>[];

  @override
  _IdomElem get element => _path.last;
  _IdomElem get _shadowElement => _shadowPath.last;
  @override
  _IdomNode get pointer => _indexes.last < _shadowElement.nodes.length
      ? _shadowElement.nodes[_indexes.last]
      : null;

  /// Creates a ServerDomContext for rendering a context to a html file
  ServerDomContext([_IdomElem root]) : _rootElem = root ?? _IdomElem(null) {
    _indexes.add(0);
    _path.add(_rootElem);
    _shadowPath.add(_rootElem);
  }

  @override
  void open(String tag, {String key, onCreate, onRemove}) {
    // Create a new pseudo-element with empty properties
    final newElem = _IdomElem(tag, key: key, parent: element);

    // Pull nodes list if matches an element from the list.
    final match = _shadowElement.nodes.indexWhere(
        (node) =>
            (node is _IdomElem) &&
            (node.tag == tag) &&
            (key == null || key == node.key),
        _indexes.last);

    if (match == -1) {
      // no match, insert new elem at the current index
      _shadowElement.nodes.insert(_indexes.last, newElem);
      _indexes.last = _indexes.last + 1;
      _path.add(newElem);
      _shadowPath.add(newElem);
      _indexes.add(0);
    } else {
      // match, remove everything between the index and the match, copy nodes
      _shadowElement.nodes.removeRange(_indexes.last, match);
      newElem.nodes.addAll((pointer as _IdomElem).nodes);
      _path.add(pointer as _IdomElem);
      _shadowPath.add(newElem);
      _indexes.add(0);
    }
  }

  @override
  void text(String value) {
    final ptr = pointer;
    if (ptr is _IdomText) {
      // Next node is a text
      if (ptr.text != value) {
        ptr.text = value;
      }
    } else {
      // Insert text node
      final newText = _IdomText(value, element);
      _shadowElement.nodes.insert(_indexes.last, newText);
      _indexes.last = _indexes.last + 1;
    }
  }

  @override
  void close({String tag}) {
    // Remove unwalked nodes
    _shadowElement.nodes.removeRange(_indexes.last, _shadowElement.nodes.length);

    // Deep copy
    _path.last.moveFrom(_shadowPath.last);
    _path.removeLast();
    _shadowPath.removeLast();
    _indexes.removeLast();
  }

  @override
  void attr(String name, String value) {
    _shadowElement.attr[name] = value;
  }

  @override
  void clazz(String name, {bool present = true}) {
    if (present) {
      _shadowElement.clazz.add(name);
    } else {
      _shadowElement.clazz.remove(name);
    }
  }

  @override
  void style(String name, String value) {
    _shadowElement.style[name] = value;
  }

  @override
  void innerHtml(String value) {
    _shadowElement.nodes = [_IdomHtml(value, element)];
    _indexes.last = 1;
  }

  @override
  void skipNode() {
    if (_indexes.last < element.nodes.length) {
      _indexes.last = _indexes.last + 1;
    }
  }

  @override
  void skipRemainingNodes() {
    _indexes.last = element.nodes.length;
  }

  @override
  void event(String name, {fn, String key, bool tracked = true}) {
    // no-op for server context
  }

  void writeHTML(StringSink out,
      {_IdomElem elem,
      String indent,
      bool indentAttr = false,
      String lineEnd,
      int indentLevel = 0}) {
    elem ??= _rootElem;

    // if elem.tag == null, then this elem is just a node list.
    if (elem.tag == null) {
      indentLevel = indentLevel - 1;
    }
    if (indent == null) indentAttr = false;
    lineEnd ??= indent != null ? '\n' : '';
    final curInd = (indent ?? '') * indentLevel;
    final nextInd = (indent ?? '') * (indentLevel + 1);
    final ml = indentAttr ? '\n$nextInd' : ' ';
    final mml = indentAttr ? '\n$nextInd$indent' : ' ';

    // tag generation, if indent is not null, ends on a new line
    if (elem.tag != null) {
      out.write('$curInd<${elem.tag}');
      var simple = true;
      if (elem.style.isNotEmpty) {
        out.write('${ml}style="$mml');
        out.write(elem.style.entries
            .map((stl) => '${stl.key}: ${stl.value};')
            .join(mml));
        out.write('"');
        simple = false;
      }
      if (elem.clazz.isNotEmpty) {
        out.write('${ml}class="$mml');
        out.write(_attrEscaper.convert(elem.clazz?.join(mml)));
        out.write('"');
        simple = false;
      }
      if (elem.attr.isNotEmpty) {
        out.write(ml);
        out.write(elem.attr.entries
            .map((atr) => '${atr.key}="${_attrEscaper.convert(atr.value)}"')
            .join(ml));
        simple = false;
      }
      if (!simple && indentAttr) {
        out.write('$lineEnd$nextInd');
      }
      out.write('>$lineEnd');
    }

    // wrting nodes, each ends in a new line if indent is not null
    for (final node in elem.nodes) {
      if (node is _IdomElem) {
        // recursive element
        writeHTML(out,
            elem: node,
            indent: indent,
            indentAttr: indentAttr,
            indentLevel: indentLevel + 1);
      } else if (node is _IdomText) {
        // text
        out.write('$nextInd${_textEscaper.convert(node.text)}$lineEnd');
      } else if (node is _IdomHtml) {
        // inline html block
        out.write(node.html);
      }
    }

    // closing tag
    if (elem.tag != null) {
      out.write('$curInd</${elem.tag}>$lineEnd');
    }
  }
}

// Base class possible node types
abstract class _IdomNode {
  _IdomElem get parent;
}

// Element node
class _IdomElem implements _IdomNode {
  String tag;
  String key;
  Map<String, String> attr;
  Set<String> clazz;
  Map<String, String> style;
  List<_IdomNode> nodes;
  @override
  _IdomElem parent;

  _IdomElem(this.tag,
      {this.key, this.attr, this.style, this.clazz, this.nodes, this.parent}) {
    attr ??= {};
    style ??= {};
    clazz ??= {};
    nodes ??= [];
  }

  // Pull every parameter from the other
  void moveFrom(_IdomElem other) {
    tag = other.tag;
    key = other.key;
    attr = other.attr;
    clazz = other.clazz;
    style = other.style;
    nodes = other.nodes;
    parent = other.parent;
  }
}

class _IdomText implements _IdomNode {
  String text;
  @override
  _IdomElem parent;
  _IdomText(this.text, this.parent);
}

class _IdomHtml implements _IdomNode {
  String html;
  @override
  _IdomElem parent;
  _IdomHtml(this.html, this.parent);
}
