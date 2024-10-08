import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/gym.dart';
import '../model/member.dart';
import '../model/sport.dart';

// Firestore instance
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// Fetch trainers from Firebase
Future<List<Member>> fetchTrainers() async {
  try {
    QuerySnapshot querySnapshot = await _firestore.collection('trainers').get();
    return querySnapshot.docs.map((doc) {
      return Member.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  } catch (e) {
    print("Error fetching trainers: $e");
    return [];
  }
}

// Fetch sports from Firebase
Future<List<Sport>> fetchSports() async {
  try {
    QuerySnapshot querySnapshot = await _firestore.collection('sports').get();
    return querySnapshot.docs.map((doc) {
      return Sport.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
  } catch (e) {
    print("Error fetching sports: $e");
    return [];
  }
}

// Load trainers and sports into the staticGymInfo object
Future<void> loadGymData() async {
  staticGymInfo.trainers = await fetchTrainers();
  staticGymInfo.sports = await fetchSports();
  print("Gym trainers and sports data loaded successfully.");
}