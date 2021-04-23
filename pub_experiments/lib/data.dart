final data = TagData(
  tags: [
    Tag(text: 'simple'),
    Tag(status: 'bad', title: 'Some failure happened.', text: 'unidentified'),
    Tag(status: 'good', href: 'https://pub.dev/', text: 'tagged'),
  ],
);

class TagData {
  final List<Tag> tags;

  TagData({
    required this.tags,
  });
}

class Tag {
  final String? status;
  final String? href;
  final String text;
  final String? title;

  Tag({
    this.status,
    this.href,
    required this.text,
    this.title,
  });
}
