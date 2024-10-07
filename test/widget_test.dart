import 'package:flutter_test/flutter_test.dart';
import 'package:gym_energy/model/member.dart';
import 'package:gym_energy/model/sport.dart';


void main() {
  // Sample data to use in the tests
  final mockSport = Sport(
    id: 's1',
    name: 'Basketball',
    price: 100.0,
  );

  final mockMember = Member(
    id: 'm1',
    firstName: 'John',
    lastName: 'Doe',
    email: 'john@example.com',
    phoneNumber: '123456789',
    createdAt: DateTime.now(),
    membershipExpiration: DateTime.now().add(Duration(days: 30)),
    totalPaid: 0.0,
    paymentDates: [],
    sports: [mockSport],
    memberType: 'trainee',
  );

  group('Member Model Tests', () {
    test('should return the full name correctly', () {
      expect(mockMember.fullName, 'John Doe');
    });

    test('should verify membership is active', () {
      expect(mockMember.isExpirationActive, true);
    });

    test('should add payment correctly', () {
      final updatedMember = mockMember.addPayment(100.0, DateTime.now());

      // Check if totalPaid is updated
      expect(updatedMember.totalPaid, 100.0);

      // Check if paymentDates length is increased
      expect(updatedMember.paymentDates.length, 1);
    });

    test('should update membership expiration correctly', () {
      final newExpiration = DateTime.now().add(Duration(days: 60));
      final updatedMember = mockMember.updateMembershipExpiration(newExpiration);

      expect(updatedMember.membershipExpiration, newExpiration);
    });

    test('should calculate total sport prices correctly', () {
      // The mock member is enrolled in one sport with a price of 100.0
      expect(mockMember.totalSportPrices(), 100.0);
    });

    test('should copy member with updated fields', () {
      final updatedMember = mockMember.copyWith(
        firstName: 'Jane',
        lastName: 'Smith',
        isActive: false,
      );

      expect(updatedMember.firstName, 'Jane');
      expect(updatedMember.lastName, 'Smith');
      expect(updatedMember.isActive, false);
    });
  });
}
