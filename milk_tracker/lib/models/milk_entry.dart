class MilkEntry {
  final int? id;
  final int customerId;
  final DateTime date;
  final double quantityLitres;
  final double pricePerLitre;
  final DateTime createdAt;

  MilkEntry({
    this.id,
    required this.customerId,
    required this.date,
    required this.quantityLitres,
    required this.pricePerLitre,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double get totalAmount => quantityLitres * pricePerLitre;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'date': date.toIso8601String().split('T')[0],
      'quantity_litres': quantityLitres,
      'price_per_litre': pricePerLitre,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory MilkEntry.fromMap(Map<String, dynamic> map) {
    return MilkEntry(
      id: map['id'],
      customerId: map['customer_id'],
      date: DateTime.parse(map['date']),
      quantityLitres: map['quantity_litres'].toDouble(),
      pricePerLitre: map['price_per_litre'].toDouble(),
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  MilkEntry copyWith({
    int? id,
    int? customerId,
    DateTime? date,
    double? quantityLitres,
    double? pricePerLitre,
    DateTime? createdAt,
  }) {
    return MilkEntry(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      date: date ?? this.date,
      quantityLitres: quantityLitres ?? this.quantityLitres,
      pricePerLitre: pricePerLitre ?? this.pricePerLitre,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
