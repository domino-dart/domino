import 'package:path/path.dart' as p;
import 'canonical.dart';

class TemplateRegistry {
  final _location = <String, String>{};

  registerAll(List<ParsedSource> parsedList) {
    for (final parsed in parsedList) {
      registerSource(parsed);
    }
  }

  registerSource(ParsedSource parsed) {
    final genPath = parsed.path.replaceAll('.html', '.g.dart');
    for (final template in parsed.templates) {
      final namespace = template.attributes['d-namespace'];
      final method = template.attributes['*'];

      _location[method] = genPath;
      if (namespace != null) {
        _location['$namespace.$method'] = genPath;
      }
    }
  }

  /// Tries to resolve a library path for the element if it is in the registry.
  /// Returns null, if element should be included as it is
  String resolveNamePath(String localName, {String basePath}) {
    if (!localName.contains('-') && !localName.contains('.')) {
      return null;
    }
    if(localName.startsWith('d.')) {
      localName = localName.substring(2);
    } else if(localName.startsWith('.')) {
      localName = localName.substring(1);
    }
    if(basePath.endsWith('.html') || basePath.endsWith('.dart')) {
      basePath = p.dirname(basePath);
    }
    return _location[localName] != null
        ? p.relative(_location[localName], from: basePath)
        : null;
  }
}
