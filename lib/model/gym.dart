import 'member.dart';
import 'sport.dart';

class Gym {
  final String name;
  final String address;
  final String openingTime;
  final String closingTime;
  final String contactNumber;
  final String email;
  final String membershipInfo;

  List<Member> trainers;  // Trainers will be fetched from Firebase
  List<Sport> sports;     // Sports will be fetched from Firebase

  Gym({
    required this.name,
    required this.address,
    required this.openingTime,
    required this.closingTime,
    required this.contactNumber,
    required this.email,
    required this.membershipInfo,
    this.trainers = const [], // Initially empty, filled later
    this.sports = const [],   // Initially empty, filled later
  });
}

// Static Gym Information
Gym staticGymInfo = Gym(
  name: "Energy Gym",
  address: "123 Fitness Ave",
  openingTime: "6:00 AM",
  closingTime: "10:00 PM",
  contactNumber: "123-456-7890",
  email: "info@energygym.com",
  membershipInfo: "Monthly and yearly memberships available",
);
