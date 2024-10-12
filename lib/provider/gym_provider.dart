import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/member.dart';
import '../model/sport.dart';
import '../model/gym.dart';

class GymProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Member> _members = [];
  Map<String, int> _sportsDistribution = {};
  bool _isLoading = true;

  // Getters
  List<Member> get members => _members;
  bool get isLoading => _isLoading;
  Map<String, int> get sportsDistribution => _sportsDistribution;

  // Add a getter for gym information
  Gym get gym => staticGymInfo; // Assuming staticGymInfo is of type Gym

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
        return Sport.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print("Error fetching sports: $e");
      return [];
    }
  }

  // Load trainers and sports into the staticGymInfo object
  Future<void> loadGymData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load trainers and sports
      staticGymInfo.trainers = await fetchTrainers();
      staticGymInfo.sports = await fetchSports();
    } catch (e) {
      print("Error loading gym data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load clients and trainers into _members list
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final QuerySnapshot clientsSnapshot = await _firestore.collection('clients').get();
      final QuerySnapshot trainersSnapshot = await _firestore.collection('trainers').get();

      _members = [
        ...clientsSnapshot.docs.map((doc) =>
            Member.fromMap(doc.data() as Map<String, dynamic>, doc.id)),
        ...trainersSnapshot.docs.map((doc) =>
            Member.fromMap(doc.data() as Map<String, dynamic>, doc.id)),
      ];

      // Calculate sports distribution while loading data
      _sportsDistribution = _calculateSportsDistribution(_members);
      await loadGymData();
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Calculate sports distribution
  Map<String, int> _calculateSportsDistribution(List<Member> members) {
    final Map<String, int> distribution = {};
    for (var member in members) {
      for (var sport in member.sports) {
        distribution[sport.name] = (distribution[sport.name] ?? 0) + 1;
      }
    }
    return distribution;
  }
}
