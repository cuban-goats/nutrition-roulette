class Food {
  final int? id;
  final String name;
  final String? description;

  const Food({this.id, required this.name, this.description});

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'description': description,
      };

  factory Food.fromMap(Map<String, Object?> map) => Food(
        id: map['id'] as int?,
        name: map['name'] as String,
        description: map['description'] as String?,
      );
}