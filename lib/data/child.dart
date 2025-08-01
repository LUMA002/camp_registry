class Child {
  final String fullName;
  final int age;
  final int? id;

  Child({required this.fullName, required this.age, this.id});

  Map<String, dynamic> toMap() {
    return {'id': id, 'full_name': fullName, 'age': age};
  }

  factory Child.fromMap(Map<String, dynamic> map) {
    return Child(
      id: map['id'] as int?,
      fullName: map['full_name'] as String,
      age: map['age'] as int,
    );
  }
}
