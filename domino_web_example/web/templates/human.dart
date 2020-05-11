class Human {
  String name;
  int age;
  String location;

  Human(this.name, this.age, this.location);

  @override
  String toString() {
    return '$name: $age';
  }
}