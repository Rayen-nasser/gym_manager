import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_energy/model/sport.dart';

class Member {
  final String id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phoneNumber;
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

  // New properties
  final String memberType; // Changed to String
  final bool isActive; // Subscription status (on or off)

  Member({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phoneNumber,
    required this.createdAt,
    required this.membershipExpiration,
    required this.totalPaid,
    required this.paymentDates,
    required this.sports,
    this.assignedTrainerId,
    this.clientIds,
    this.notes,
    required this.memberType, // New parameter
    this.isActive = true, // New parameter
  });

  String get fullName => '$firstName $lastName';

  bool get isExpirationActive => membershipExpiration.isAfter(DateTime.now());

  factory Member.fromMap(Map<String, dynamic> data, String documentId) {
    final memberType = data['memberType'] ?? 'unknown';

    return Member(
      id: documentId,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      membershipExpiration: (data['membershipExpiration'] != null && data['membershipExpiration'] is Timestamp)
          ? (data['membershipExpiration'] as Timestamp).toDate()
          : DateTime.now(), // Default to current date if null
      totalPaid: (data['totalPaid'] ?? 0.0).toDouble(),
      paymentDates: (data['paymentDates'] as List<dynamic>? ?? [])
          .map((date) => (date as Timestamp).toDate())
          .toList(),
      sports: (data['sports'] as List<dynamic>? ?? [])
          .map((item) => Sport.fromMap(item as Map<String, dynamic>, item["id"]))
          .toList(),
      assignedTrainerId: data['assignedTrainerId'],
      clientIds: (data['clientIds'] as List<dynamic>?)?.cast<String>(),
      notes: data['notes'],
      memberType: memberType,
      isActive: data['isActive'] ?? false,
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
      'memberType': memberType, // Save as String
      'isSubscriber': isActive, // Save subscription status
    };
  }

  // Add a payment
  Member addPayment(double amount, DateTime paymentDate) {
    List<DateTime> updatedPaymentDates = List.from(paymentDates)..add(paymentDate);
    return Member(
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
      memberType: memberType,
      isActive: isActive,
    );
  }

  Member updateMembershipExpiration(DateTime newExpirationDate) {
    List<DateTime> updatedPaymentDates = List.from(paymentDates)..add(newExpirationDate);
    return Member(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phoneNumber,
      createdAt: createdAt,
      membershipExpiration: newExpirationDate,
      totalPaid: totalPaid,
      paymentDates: updatedPaymentDates,
      sports: sports,
      assignedTrainerId: assignedTrainerId,
      clientIds: clientIds,
      notes: notes,
      memberType: memberType,
      isActive: isActive,
    );
  }

  // Method to calculate the total price of all enrolled sports
  double totalSportPrices() {
    return sports.fold(0.0, (sum, sport) => sum + sport.price);
  }

  // Add a copyWith method
  Member copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? membershipExpiration,
    double? totalPaid,
    List<DateTime>? paymentDates,
    List<Sport>? sports,
    String? assignedTrainerId,
    List<String>? clientIds,
    String? notes,
    bool? isActive,
    String? memberType, // Changed to String
    bool? isSubscriber, // Updated to match
  }) {
    return Member(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      membershipExpiration: membershipExpiration ?? this.membershipExpiration,
      totalPaid: totalPaid ?? this.totalPaid,
      paymentDates: paymentDates ?? this.paymentDates,
      sports: sports ?? this.sports,
      assignedTrainerId: assignedTrainerId ?? this.assignedTrainerId,
      clientIds: clientIds ?? this.clientIds,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
      memberType: memberType ?? this.memberType, // Update memberType
    );
  }

  // New method to calculate revenue for a specific month
  double calculateRevenueForMonth(DateTime month) {
    return paymentDates
        .where((date) =>
    date.year == month.year && date.month == month.month)
        .fold(0.0, (sum, date) {
      int paymentIndex = paymentDates.indexOf(date);
      if (paymentIndex < paymentDates.length - 1) {
        return sum + (totalPaid / paymentDates.length);
      } else {
        return sum + (totalPaid - (totalPaid / paymentDates.length) * (paymentDates.length - 1));
      }
    });
  }

  // Static method to calculate total revenue for a list of members in a specific month
  static double calculateTotalRevenueForMonth(List<Member> members, DateTime month) {
    return members.fold(0.0, (sum, member) => sum + member.calculateRevenueForMonth(month));
  }
}
