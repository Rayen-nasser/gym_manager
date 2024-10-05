import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_energy/model/sport.dart';

enum MemberType {
  personal, // Regular gym member
  trainer   // Gym trainer
}

class Client {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final DateTime createdAt;
  final DateTime membershipExpiration;

  // Payment tracking (cash only)
  final double totalPaid;
  final List<DateTime> paymentDates;

  // Sports/Training information
  final List<Sport> sports; // For personal: enrolled sports, For trainer: sports they teach
  final String? assignedTrainerId; // Only for personal members - their trainer's ID
  final List<String>? clientIds; // Only for trainers - list of their clients' IDs

  // Additional information
  final String? notes;

  Client({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.createdAt,
    required this.membershipExpiration,
    required this.totalPaid,
    required this.paymentDates,
    required this.sports,
    this.assignedTrainerId,
    this.clientIds,
    this.notes,
  });

  String get fullName => '$firstName $lastName';

  bool get isActive => membershipExpiration.isAfter(DateTime.now());

  factory Client.fromMap(Map<String, dynamic> data, String documentId) {
    return Client(
      id: documentId,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      membershipExpiration: (data['membershipExpiration'] as Timestamp).toDate(),
      totalPaid: (data['totalPaid'] ?? 0.0).toDouble(),
      paymentDates: (data['paymentDates'] as List<dynamic>? ?? [])
          .map((date) => (date as Timestamp).toDate())
          .toList(),
      sports: (data['sports'] as List<dynamic>? ?? [])
          .map((item) => Sport.fromMap(item as Map<String, dynamic>))
          .toList(),
      assignedTrainerId: data['assignedTrainerId'],
      clientIds: (data['clientIds'] as List<dynamic>?)?.cast<String>(),
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'createdAt': Timestamp.fromDate(createdAt),
      'membershipExpiration': Timestamp.fromDate(membershipExpiration),
      'totalPaid': totalPaid,
      'paymentDates': paymentDates.map((date) => Timestamp.fromDate(date)).toList(),
      'sports': sports.map((sport) => sport.toMap()).toList(),
      'assignedTrainerId': assignedTrainerId,
      'clientIds': clientIds,
      'notes': notes,
    };
  }

  // Add a payment
  Client addPayment(double amount, DateTime paymentDate) {
    List<DateTime> updatedPaymentDates = List.from(paymentDates)..add(paymentDate);
    return Client(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phoneNumber,
      createdAt: createdAt,
      membershipExpiration: membershipExpiration,
      totalPaid: totalPaid + amount,
      paymentDates: updatedPaymentDates,
      sports: sports,
      assignedTrainerId: assignedTrainerId,
      clientIds: clientIds,
      notes: notes,
    );
  }


  // Add a client (for trainers only)
  Client? addClient(String clientId) {
    List<String> updatedClientIds = List.from(clientIds ?? [])..add(clientId);
    return Client(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phoneNumber,
      createdAt: createdAt,
      membershipExpiration: membershipExpiration,
      totalPaid: totalPaid,
      paymentDates: paymentDates,
      sports: sports,
      assignedTrainerId: assignedTrainerId,
      clientIds: updatedClientIds,
      notes: notes,
    );
  }
}