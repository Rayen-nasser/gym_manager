import 'package:cloud_firestore/cloud_firestore.dart'; // Needed for Timestamp

enum UserRole {
  admin,
  employer,
}

class User {
  final String id; // Unique ID for each user
  final String firstname;
  final String lastname;
  final String email; // Email for login/authentication
  final UserRole role; // Role can only be admin or employer
  final DateTime createdAt; // Date when the user was created

  // Constructor
  User({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  // Method to display the full name
  String getFullName() {
    return '$firstname $lastname';
  }

  // Method to check if user is admin
  bool isAdmin() {
    return role == UserRole.admin;
  }

  // Method to check if user is employer
  bool isEmployer() {
    return role == UserRole.employer;
  }

  // Method to create a User from a map (e.g., from Firestore document)
  factory User.fromMap(Map<String, dynamic> data, String documentId) {
    return User(
      id: documentId,
      firstname: data['firstname'] ?? '',
      lastname: data['lastname'] ?? '',
      email: data['email'] ?? '',
      role: (data['role'] == 'admin') ? UserRole.admin : UserRole.employer,
      createdAt: (data['createdAt'] as Timestamp).toDate(), // Convert Firestore Timestamp to DateTime
    );
  }

  // Method to convert User object to map (e.g., for saving to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'role': role == UserRole.admin ? 'admin' : 'employer',
      'createdAt': Timestamp.fromDate(createdAt), // Convert DateTime to Firestore Timestamp
    };
  }
}
