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

  // Factory constructor to create a Sport instance from a Map (Firestore or JSON data)
  factory Sport.fromMap(Map<String, dynamic> data, String documentId) {
    return Sport(
      id: documentId, // Use the Firestore document ID as the sport ID
      name: data['name'] ?? 'Unnamed Sport',
      price: (data['price'] ?? 0).toDouble(),
      description: data['description'],
      sessionDuration: data['sessionDuration'] ?? 60,
    );
  }

  // Convert a Sport instance to a Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'description': description,
      'sessionDuration': sessionDuration,
    };
  }
}
