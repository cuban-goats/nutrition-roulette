class Food {
  final int? id;
  final String name;

  const Food({this.id, required this.name});

  Map<String, Object?> toMap() => {'id': id, 'name': name};

  factory Food.fromMap(Map<String, Object?> map) => Food(
        id: map['id'] as int?,
        name: map['name'] as String,
      );
}