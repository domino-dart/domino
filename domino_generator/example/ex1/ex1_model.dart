class Example {
  String? text;
  String? name;
  int? number;
  bool get cond1 => true;
  bool get cond2 => true;
  late List<Item> items;
}

class Item {
  late bool visible;
  String? label;
  String clazz = 'default';
}
