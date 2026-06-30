// lib/data/models/supplier.dart
// نموذج المورد — أسماء الحقول تطابق قاعدة البيانات
class Supplier {
  final String id; // UUID v4
  final String name;
  final String? phone;
  final String? notes;

  Supplier({
    required this.id,
    required this.name,
    this.phone,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'notes': notes,
    };
  }

  factory Supplier.fromMap(Map<String, dynamic> map) {
    return Supplier(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      notes: map['notes'] as String?,
    );
  }

  Supplier copyWith({
    String? id,
    String? name,
    String? phone,
    String? notes,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() => 'Supplier(id: $id, name: $name)';
}
