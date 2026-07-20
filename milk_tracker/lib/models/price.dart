class Price {
  final int? id;
  final double pricePerLitre;
  final DateTime effectiveFrom;
  final DateTime? effectiveTo;

  Price({
    this.id,
    required this.pricePerLitre,
    required this.effectiveFrom,
    this.effectiveTo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'price_per_litre': pricePerLitre,
      'effective_from': effectiveFrom.toIso8601String().split('T')[0],
      'effective_to': effectiveTo?.toIso8601String().split('T')[0],
    };
  }

  factory Price.fromMap(Map<String, dynamic> map) {
    return Price(
      id: map['id'],
      pricePerLitre: map['price_per_litre'].toDouble(),
      effectiveFrom: DateTime.parse(map['effective_from']),
      effectiveTo: map['effective_to'] != null
          ? DateTime.parse(map['effective_to'])
          : null,
    );
  }

  bool get isActive => effectiveTo == null;
}
