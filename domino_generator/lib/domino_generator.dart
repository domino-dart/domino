import 'dart:io';

import 'package:path/path.dart' as p;

import 'src/canonical.dart';
import 'src/component_generator.dart';
//import 'src/ddom_generator.dart';

Future<CompilationSummary> compileFile(
  String path, {
  bool debugParse = false,
}) async {
  final file = File(path);
  final parsed = parseFileToCanonical(path);
  if (debugParse) {
    final debugContent = parsed.templates
        .map((e) => '${e.toXmlString(pretty: true)}\n')
        .join('\n');
    await _replaceExtension(file, '.g.html').writeAsString(debugContent);
  }
  final gs = parseHtmlToSources(await file.readAsString());
  final dartUpdated =
      await _updateFile(_replaceExtension(file, '.g.dart'), gs.dartFileContent);
  final sassUpdated =
      await _updateFile(_replaceExtension(file, '.g.scss'), gs.sassFileContent);

//  final gs = generateSource(await file.readAsString());
//  await _updateFile(
//      File(p.setExtension(file.path, '.d.dart')), gs.dartFileContent);
//
  return CompilationSummary(
    hasSass: gs.hasSassFileContent,
    dartUpdated: dartUpdated,
    sassUpdated: sassUpdated,
  );
}

class CompilationSummary {
  final bool hasSass;
  final bool dartUpdated;
  final bool sassUpdated;

  CompilationSummary({
    required this.hasSass,
    required this.dartUpdated,
    required this.sassUpdated,
  });
}

Future<void> compileDirectory(
  String path, {
  bool recursive = true,
  bool debugParse = false,
  String? libraryName,
  String? sassName,
}) async {
  final stream = Directory(path)
      .list(recursive: recursive)
      .where((e) => e is File)
      .cast<File>()
      .where((f) => f.path.endsWith('.html') && !f.path.endsWith('.g.html'));

  final dartFilePaths = <String>[];
  final sassFilePaths = <String>[];
  await for (final file in stream) {
    final cs = await compileFile(file.path, debugParse: debugParse);
    final relativePath = p.relative(file.path, from: path);
    dartFilePaths.add(p.setExtension(relativePath, '.g.dart'));
    if (cs.hasSass) {
      sassFilePaths.add(p.setExtension(relativePath, '.g.scss'));
    }
  }

  if (libraryName != null) {
    dartFilePaths.sort();
    final libraryContent = dartFilePaths.map((p) => 'export \'$p\';\n').join();
    await _updateFile(File(p.join(path, libraryName)), libraryContent);
  }

  if (sassName != null) {
    sassFilePaths.sort();
    final sassContent = sassFilePaths.map((p) => '@import "$p";\n').join();
    await _updateFile(File(p.join(path, sassName)), sassContent);
  }
}

File _replaceExtension(File orig, String ext) {
  return File(p.setExtension(orig.path, ext));
}

Future<bool> _updateFile(File target, String content) async {
  if (content == null || content.isEmpty) {
    if (await target.exists()) {
      await target.delete();
      return true;
    }
  } else {
    final actual = (await target.exists()) ? await target.readAsString() : null;
    if (actual == content) return false;
    await target.writeAsString(content);
    return true;
  }
  return false;
}
