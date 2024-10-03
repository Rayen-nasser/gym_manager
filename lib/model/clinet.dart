import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_energy/model/sport.dart';

class Client {
  final String id; // Unique client ID
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final List<Sport> sports; // List of sports the client is enrolled in
  final DateTime createdAt; // Date when the client was added
  final DateTime membershipExpiration; // Expiration date for the client's membership
  final double totalPaid; // Total amount paid by the client
  final List<DateTime> datesPaid; // List of payment dates
  final DateTime nextPaymentDate; // Next payment date
  final String trainingType; // Personal or Trainer
  final String? trainerName; // Trainer's name if applicable
  final String? additionalInfo; // Long text information about the client

  // Constructor
  Client({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.sports,
    required this.createdAt,
    required this.membershipExpiration,
    required this.totalPaid,
    required this.datesPaid,
    required this.nextPaymentDate,
    required this.trainingType, // Required field
    this.trainerName, // Optional field
    this.additionalInfo, // Optional long text field
  });

  // Method to display the full name
  String getFullName() {
    return '$firstName $lastName';
  }

  // Method to calculate total paid from sports prices
  double getTotalPaidFromSports() {
    return sports.fold(0, (sum, sport) => sum + sport.price);
  }

  // Method to calculate the next payment date based on membershipExpiration
  DateTime calculateNextPaymentDate() {
    return membershipExpiration.add(const Duration(days: 30));
  }

  // Method to add a paid date
  void addPaymentDate(DateTime date) {
    if (!datesPaid.contains(date)) {
      datesPaid.add(date);
    }
  }

  // Factory method to create a Client from a map (e.g., Firestore document)
  factory Client.fromMap(Map<String, dynamic> data, String documentId) {
    // Cast sports data to List<Sport>
    List<Sport> sportList = (data['sports'] as List<dynamic>? ?? [])
        .map((item) => Sport.fromMap(item as Map<String, dynamic>))
        .toList();

    // Cast datesPaid data to List<DateTime>
    List<DateTime> datesPaidList = (data['datesPaid'] as List<dynamic>? ?? [])
        .map((item) => (item as Timestamp).toDate())
        .toList();

    return Client(
      id: documentId,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      sports: sportList,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      membershipExpiration: (data['membershipExpiration'] as Timestamp).toDate(),
      totalPaid: data['totalPaid']?.toDouble() ?? 0.0,
      datesPaid: datesPaidList,
      nextPaymentDate: (data['membershipExpiration'] as Timestamp)
          .toDate()
          .add(const Duration(days: 30)), // Calculate next payment date
      trainingType: data['trainingType'] ?? 'personal', // Default to personal if not provided
      trainerName: data['trainerName'], // Nullable
      additionalInfo: data['additionalInfo'], // Nullable, long text info
    );
  }

  // Method to convert Client object to map (e.g., for saving to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'sports': sports.map((sport) => sport.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'membershipExpiration': Timestamp.fromDate(membershipExpiration),
      'totalPaid': totalPaid,
      'datesPaid': datesPaid.map((date) => Timestamp.fromDate(date)).toList(),
      'nextPaymentDate': Timestamp.fromDate(nextPaymentDate),
      'trainingType': trainingType,
      'trainerName': trainerName, // Optional field
      'additionalInfo': additionalInfo, // Optional long text field
    };
  }
}
