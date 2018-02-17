List<String> flatClasses(value) => _flat(value, null);

List<String> _flat(value, List<String> classes) {
  if (value == null) {
    return classes;
  }
  if (value is String) {
    classes ??= [];
    classes.add(value);
  } else if (value is List) {
    classes ??= [];
    for (var item in value) {
      _flat(item, classes);
    }
  } else {
    throw new Exception('Unknown class value: $value');
  }
  return classes;
}
