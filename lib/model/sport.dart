import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Sport {
  final String id;
  final String name;
  final double price;
  final String description;
  final int sessionDuration;

  Sport({
    String? id,
    required this.name,
    required this.price,
    required this.description,
    required this.sessionDuration,
  }) : id = id ?? const Uuid().v4(); // Generate UUID if not provided

  factory Sport.fromMap(Map<String, dynamic> data, String documentId) {
    return Sport(
      id: documentId,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      description: data['description'] ?? '',
      sessionDuration: data['sessionDuration'] ?? 0,
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