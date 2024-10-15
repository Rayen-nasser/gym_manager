import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  admin,
  employer,
}

class UserModel {
  final String id; // Unique ID for each user
  final String username;
  final String email; // Email for login/authentication
  final UserRole role; // Role can only be admin or employer
  final DateTime createdAt; // Date when the user was created

  // Constructor
  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  // Method to check if user is admin
  bool isAdmin() {
    return role == UserRole.admin;
  }

  // Method to check if user is employer
  bool isEmployer() {
    return role == UserRole.employer;
  }

  // Method to create a UserModel from a map (e.g., from Firestore document)
  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      id: documentId,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      role: (data['role'] == 'admin') ? UserRole.admin : UserRole.employer,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Method to convert UserModel object to map (e.g., for saving to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'role': role == UserRole.admin ? 'admin' : 'employer',
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}