
class Sport {
  final String id;
  final String name;
  final double price;
  final String? description;
  final int sessionDuration; // in minutes

  Sport({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.sessionDuration = 60,
  });

  factory Sport.fromMap(Map<String, dynamic> data) {
    return Sport(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      description: data['description'],
      sessionDuration: data['sessionDuration'] ?? 60,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'sessionDuration': sessionDuration,
    };
  }
}
