import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_energy/model/member.dart';
import 'package:gym_energy/model/sport.dart';
import 'mocks.mocks.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockCollectionsRef mockClientsCollection;
  late MockCollectionsRef mockTrainersCollection;
  late MockDocumentReference mockDocRef;
  late MockWriteBatch mockBatch;
  late Member testMember;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockClientsCollection = MockCollectionsRef();
    mockTrainersCollection = MockCollectionsRef();
    mockDocRef = MockDocumentReference();
    mockBatch = MockWriteBatch();

    testMember = Member(
      id: 'test-id',
      firstName: 'John',
      lastName: 'Doe',
      email: 'john@example.com',
      phoneNumber: '1234567890',
      createdAt: DateTime.now(),
      membershipExpiration: DateTime.now().add(Duration(days: 30)),
      totalPaid: 250.0,
      paymentDates: [DateTime.now()],
      sports: [
        Sport(
            id: '1',
            name: 'Swimming',
            price: 100.0,
            description: 'Swimming lessons'
        )
      ],
      memberType: 'trainee',
    );
  });

  group('Firebase Member Operations', () {
    test('Adding new member to Firebase', () async {
      // Act
      await fakeFirestore.collection('clients').add(testMember.toMap());

      // Assert
      final snapshot = await fakeFirestore.collection('clients').get();
      expect(snapshot.docs.length, 1);
      expect(snapshot.docs.first.data()['firstName'], 'John');
      expect(snapshot.docs.first.data()['lastName'], 'Doe');
    });

    test('Updating existing member in Firebase', () async {
      // Arrange
      final docRef = await fakeFirestore.collection('clients').add(testMember.toMap());
      final updatedMember = Member(
        id: docRef.id,
        firstName: 'Jane',
        lastName: 'Smith',
        email: 'jane@example.com',
        phoneNumber: testMember.phoneNumber,
        createdAt: testMember.createdAt,
        membershipExpiration: testMember.membershipExpiration,
        totalPaid: testMember.totalPaid,
        paymentDates: testMember.paymentDates,
        sports: testMember.sports,
        memberType: testMember.memberType,
      );

      // Act
      await docRef.update(updatedMember.toMap());

      // Assert
      final snapshot = await docRef.get();
      expect(snapshot.data()?['firstName'], 'Jane');
      expect(snapshot.data()?['lastName'], 'Smith');
      expect(snapshot.data()?['email'], 'jane@example.com');
    });

    test('Adding client to trainer', () async {
      // Arrange
      const trainerId = 'trainer-123';
      const clientId = 'client-456';

      await fakeFirestore.collection('trainers').doc(trainerId).set({
        'clientIds': <String>[],
        'firstName': 'Trainer',
        'lastName': 'One'
      });

      // Act
      await fakeFirestore
          .collection('trainers')
          .doc(trainerId)
          .update({
        'clientIds': FieldValue.arrayUnion([clientId])
      });

      // Assert
      final snapshot = await fakeFirestore.collection('trainers').doc(trainerId).get();
      final clientIds = List<String>.from(snapshot.data()?['clientIds'] ?? []);
      expect(clientIds, contains(clientId));
    });

    test('Handles non-existent member during update', () async {
      // Act & Assert
      expect(
            () => fakeFirestore
            .collection('clients')
            .doc('non-existent-id')
            .update(testMember.toMap()),
        throwsA(isA<FirebaseException>()),
      );
    });
  });
}

// Firebase operations to test
Future<void> addMemberToFirebase(Member member, FirebaseFirestore firestore) async {
  await firestore.collection('clients').add(member.toMap());
}

Future<void> updateMemberInFirebase(Member member, FirebaseFirestore firestore) async {
  final memberRef = firestore.collection('clients').doc(member.id);
  final doc = await memberRef.get();

  if (!doc.exists) {
    throw Exception('Member document not found');
  }

  await memberRef.update(member.toMap());
}

Future<void> addClientToTrainer(String clientId, String trainerId, FirebaseFirestore firestore) async {
  await firestore
      .collection('trainers')
      .doc(trainerId)
      .update({
    'clientIds': FieldValue.arrayUnion([clientId])
  });
}