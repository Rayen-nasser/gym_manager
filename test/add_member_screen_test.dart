import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_energy/model/sport.dart';
import 'package:gym_energy/model/member.dart';

void main() {
  group('Member Model Tests', () {
    late DateTime now;
    late Sport testSport1;
    late Sport testSport2;
    late Member testMember;

    setUp(() {
      now = DateTime.now();
      testSport1 = Sport(
        id: '1',
        name: 'Swimming',
        price: 100.0,
        description: 'Swimming lessons',
      );
      testSport2 = Sport(
        id: '2',
        name: 'Tennis',
        price: 150.0,
        description: 'Tennis lessons',
      );

      testMember = Member(
        id: 'test-id',
        firstName: 'John',
        lastName: 'Doe',
        email: 'john@example.com',
        phoneNumber: '1234567890',
        createdAt: now,
        membershipExpiration: now.add(Duration(days: 30)),
        totalPaid: 250.0,
        paymentDates: [now],
        sports: [testSport1, testSport2],
        memberType: 'trainee',
        isActive: true,
      );
    });

    group('Constructor and Basic Properties', () {
      test('creates instance with required properties', () {
        expect(testMember.id, equals('test-id'));
        expect(testMember.firstName, equals('John'));
        expect(testMember.lastName, equals('Doe'));
        expect(testMember.email, equals('john@example.com'));
        expect(testMember.phoneNumber, equals('1234567890'));
        expect(testMember.totalPaid, equals(250.0));
        expect(testMember.sports.length, equals(2));
        expect(testMember.memberType, equals('trainee'));
        expect(testMember.isActive, isTrue);
      });

      test('fullName getter returns correct format', () {
        expect(testMember.fullName, equals('John Doe'));
      });

      test('isExpirationActive returns correct status', () {
        final expiredMember = testMember.copyWith(
          membershipExpiration: now.subtract(Duration(days: 1)),
        );
        expect(testMember.isExpirationActive, isTrue);
        expect(expiredMember.isExpirationActive, isFalse);
      });
    });

    group('fromMap and toMap', () {
      test('converts from map correctly', () {
        final Map<String, dynamic> testMap = {
          'firstName': 'John',
          'lastName': 'Doe',
          'email': 'john@example.com',
          'phoneNumber': '1234567890',
          'createdAt': Timestamp.fromDate(now),
          'membershipExpiration': Timestamp.fromDate(now.add(Duration(days: 30))),
          'totalPaid': 250.0,
          'paymentDates': [Timestamp.fromDate(now)],
          'sports': [testSport1.toMap(), testSport2.toMap()],
          'memberType': 'trainee',
          'isActive': true,
        };

        final member = Member.fromMap(testMap, 'test-id');
        expect(member.firstName, equals('John'));
        expect(member.lastName, equals('Doe'));
        expect(member.sports.length, equals(2));
        expect(member.memberType, equals('trainee'));
      });

      test('converts to map correctly', () {
        final map = testMember.toMap();
        expect(map['firstName'], equals('John'));
        expect(map['lastName'], equals('Doe'));
        expect(map['email'], equals('john@example.com'));
        expect(map['sports'].length, equals(2));
        expect(map['memberType'], equals('trainee'));
      });
    });

    group('Payment Methods', () {
      test('addPayment creates new instance with updated payment info', () {
        final newPaymentAmount = 100.0;
        final newPaymentDate = DateTime.now();

        final updatedMember = testMember.addPayment(newPaymentAmount, newPaymentDate);

        expect(updatedMember.totalPaid, equals(testMember.totalPaid + newPaymentAmount));
        expect(updatedMember.paymentDates.length, equals(testMember.paymentDates.length + 1));
        expect(updatedMember.paymentDates.last, equals(newPaymentDate));
      });

      test('totalSportPrices calculates correct total', () {
        expect(testMember.totalSportPrices(), equals(250.0)); // 100 + 150
      });
    });

    group('Membership Methods', () {
      test('updateMembershipExpiration creates new instance with updated expiration', () {
        final newExpirationDate = now.add(Duration(days: 60));
        final updatedMember = testMember.updateMembershipExpiration(newExpirationDate);

        expect(updatedMember.membershipExpiration, equals(newExpirationDate));
        expect(updatedMember.paymentDates.length, equals(testMember.paymentDates.length + 1));
      });
    });

    group('Trainer-specific Methods', () {
      test('addClient adds client ID for trainer members', () {
        final trainerMember = testMember.copyWith(
          memberType: 'trainer',
          clientIds: [],
        );

        final updatedTrainer = trainerMember.addClient('new-client-id');

        expect(updatedTrainer, isNotNull);
        expect(updatedTrainer?.clientIds?.length, equals(1));
        expect(updatedTrainer?.clientIds?.first, equals('new-client-id'));
      });
    });

    group('copyWith Method', () {
      test('updates specified fields while keeping others unchanged', () {
        final updatedMember = testMember.copyWith(
          firstName: 'Jane',
          lastName: 'Smith',
          isActive: false,
        );

        expect(updatedMember.firstName, equals('Jane'));
        expect(updatedMember.lastName, equals('Smith'));
        expect(updatedMember.isActive, isFalse);
        expect(updatedMember.email, equals(testMember.email));
        expect(updatedMember.phoneNumber, equals(testMember.phoneNumber));
      });

      test('handles null values correctly', () {
        final updatedMember = testMember.copyWith();

        expect(updatedMember.firstName, equals(testMember.firstName));
        expect(updatedMember.lastName, equals(testMember.lastName));
        expect(updatedMember.email, equals(testMember.email));
      });
    });

    group('Edge Cases', () {
      test('fromMap handles missing or null values', () {
        final Map<String, dynamic> incompleteMap = {
          'createdAt': Timestamp.fromDate(now),
          'membershipExpiration': Timestamp.fromDate(now),
        };

        final member = Member.fromMap(incompleteMap, 'test-id');

        expect(member.firstName, equals(''));
        expect(member.lastName, equals(''));
        expect(member.email, equals(''));
        expect(member.sports, isEmpty);
      });

      test('handles empty sports list', () {
        final memberWithNoSports = testMember.copyWith(sports: []);
        expect(memberWithNoSports.totalSportPrices(), equals(0.0));
      });
    });
  });
}