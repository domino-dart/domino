import 'package:domino/src/experimental/idom.dart' as _i1;
import 'data.dart' as _i2;

void renderTags(_i1.DomContext $d, {required _i2.TagData data}) {
  $d.open('div');
  for (final tag in data.tags) {
    if (tag.href != null) {
      $d.open('a');
      $d.attr('href', '${tag.href}');
      $d.clazz('package-tag');
      if (tag.status != null) {
        $d.clazz('tag.status!');
      }
      if (tag.title != null) {
        $d.attr('title', tag.title!);
      }
      $d.text('\n                    ${tag.text}\n                ');
      $d.close();
    } else {
      $d.open('span');
      $d.text('${tag.text}');
      $d.close();
    }
  }
  $d.close();
}
