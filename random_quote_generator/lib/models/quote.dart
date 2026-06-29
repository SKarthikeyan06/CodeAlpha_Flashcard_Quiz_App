class Quote {
  final int? id;
  final String text;
  final String author;
  final String category;
  bool isLiked;
  final bool isUserAdded;

  Quote({
    this.id,
    required this.text,
    required this.author,
    required this.category,
    this.isLiked = false,
    this.isUserAdded = false,
  });

  factory Quote.fromMap(Map<String, dynamic> map) => Quote(
    id: map['id'],
    text: map['text'] ?? '',
    author: map['author'] ?? 'Unknown',
    category: map['category'] ?? 'General',
    isLiked: map['is_liked'] == 1,
    isUserAdded: map['is_user_added'] == 1,
  );

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'text': text,
      'author': author,
      'category': category,
      'is_liked': isLiked ? 1 : 0,
      'is_user_added': isUserAdded ? 1 : 0,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  Quote copyWith({
    int? id,
    String? text,
    String? author,
    String? category,
    bool? isLiked,
    bool? isUserAdded,
  }) {
    return Quote(
      id: id ?? this.id,
      text: text ?? this.text,
      author: author ?? this.author,
      category: category ?? this.category,
      isLiked: isLiked ?? this.isLiked,
      isUserAdded: isUserAdded ?? this.isUserAdded,
    );
  }
}
