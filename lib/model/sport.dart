class Sport {
  final String name;
  final double price; // Changed to double for monetary value

  Sport({
    required this.name,
    required this.price,
  });

  // Factory method to create a Sport from a map
  factory Sport.fromMap(Map<String, dynamic> data) {
    return Sport(
      name: data['name'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(), // Ensure it's a double
    );
  }

  // Method to convert Sport object to map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
    };
  }
}
