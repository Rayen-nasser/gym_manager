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
          .map((item) => Sport.fromMap(item, item['id']))
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
      'isActive': isActive, // Save subscription status
    };
  }

  // Add a payment
  Member addPayment(double amount, DateTime paymentDate) {
    List<DateTime> updatedPaymentDates = List.from(paymentDates)..add(paymentDate);

    // Check if the payment for the current month is already made
    bool currentMonthPaid = paymentDate.year == DateTime.now().year && paymentDate.month == DateTime.now().month;

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
    final now = DateTime.now();

    // If the membership expiration is in the future (or today), only charge for the current month
    if (membershipExpiration.isAfter(now) || membershipExpiration.isAtSameMomentAs(now)) {
      // Charge for only one month if the membership hasn't expired yet
      return sports.fold(0.0, (sum, sport) => sum + sport.price);
    }

    // If the membership has expired, calculate how many months have passed since expiration
    final monthsSinceExpiration = (now.year * 12 + now.month) - (membershipExpiration.year * 12 + membershipExpiration.month);

    // Add 1 to include the current month in the charge
    final monthsToPayFor = monthsSinceExpiration + 1;

    // Calculate total price by multiplying sports prices by the number of months to pay for
    return sports.fold(0.0, (sum, sport) => sum + (sport.price * monthsToPayFor));
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
    List<DateTime>? unpaidMonths, // Include unpaidMonths for copy
    bool? isPaid, // Include isPaid for copy
    List<Sport>? sports,
    String? assignedTrainerId,
    List<String>? clientIds,
    String? notes,
    bool? isActive,
    String? memberType, // Changed to String
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
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      memberType: memberType ?? this.memberType, // Update memberType
    );
  }

  // Static method to create a Member with default values
  static Member createDefault() {
    return Member(
      id: '',
      firstName: '',
      lastName: '',
      email: '',
      phoneNumber: '',
      createdAt: DateTime.now(),
      membershipExpiration: DateTime.now().add(Duration(days: 30)),
      totalPaid: 0.0,
      paymentDates: [],
      sports: [],
      assignedTrainerId: null,
      clientIds: [],
      notes: null,
      memberType: 'standard', // Default to standard member type
      isActive: true, // Default to active
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
