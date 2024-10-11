import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_energy/model/member.dart' as client_model;
import 'package:gym_energy/model/sport.dart';

import '../model/member.dart'; // Assuming you have a Sport model

class MembersProvider with ChangeNotifier {
  List<client_model.Member> _allMembers = [];
  List<client_model.Member> _filteredMembers = [];
  List<Sport> _sports = [];

  String _searchQuery = '';
  String selectedFilter = 'All';
  String? selectedSport;
  bool showExpiredOnly = false;
  bool showActiveMembers = true;

  // Getter for filtered members
  List<client_model.Member> get filteredMembers => _filteredMembers;

  // Getter for sports
  List<Sport> get availableSports => _sports;

  // Fetch all members (both clients and trainers) from Firestore
  Future<void> fetchMembers() async {
    final clientSnapshot = await FirebaseFirestore.instance.collection('clients').get();
    final trainerSnapshot = await FirebaseFirestore.instance.collection('trainers').get();

    _allMembers = [
      ...clientSnapshot.docs.map((doc) => client_model.Member.fromMap(doc.data() as Map<String, dynamic>, doc.id)),
      ...trainerSnapshot.docs.map((doc) => client_model.Member.fromMap(doc.data() as Map<String, dynamic>, doc.id)),
    ];

    _applyFilters();
    notifyListeners();
  }

  // Update search query and reapply filters
  void updateSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  // Update filters and reapply them
  void updateFilters({
    required String filter,
    required String? sport,
    required bool expiredOnly,
    required bool activeMembers,
  }) {
    selectedFilter = filter;
    selectedSport = sport;
    showExpiredOnly = expiredOnly;
    showActiveMembers = activeMembers;
    _applyFilters();
  }

  // Apply the filters to _allMembers and set _filteredMembers
  void _applyFilters() {
    _filteredMembers = _allMembers.where((client) {
      // Filter by Clients or Trainers
      final matchesFilter = selectedFilter == 'All' ||
          (selectedFilter == 'Clients' && client.memberType == "client") ||
          (selectedFilter == 'Trainers' && client.memberType == "trainer");

      // Filter by sport
      final matchesSport = selectedSport == null ||
          client.sports.any((sport) => sport.name == selectedSport);

      // Filter by search query
      final matchesSearch = _searchQuery.isEmpty ||
          client.firstName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          client.lastName.toLowerCase().contains(_searchQuery.toLowerCase());

      // Filter by membership expiration status
      final matchesExpiration = !showExpiredOnly || !client.isExpirationActive;

      // Filter by active status
      final matchesActiveStatus = showActiveMembers ? client.isActive : !client.isActive;

      return matchesFilter && matchesSport && matchesSearch && matchesExpiration && matchesActiveStatus;
    }).toList();

    notifyListeners();
  }

  // Edit member details
  Future<void> editMember(client_model.Member updatedMember) async {
    final collection = updatedMember.memberType == "trainer" ? "trainers" : "clients";
    await FirebaseFirestore.instance.collection(collection).doc(updatedMember.id).update(updatedMember.toMap());

    int index = _allMembers.indexWhere((member) => member.id == updatedMember.id);
    if (index != -1) {
      _allMembers[index] = updatedMember;
      _applyFilters();
    }
  }

  // Delete a member
  Future<void> deleteMember(client_model.Member member) async {
    final collection = member.memberType == "trainer" ? "trainers" : "clients";
    await FirebaseFirestore.instance.collection(collection).doc(member.id).delete();

    _allMembers.removeWhere((m) => m.id == member.id);
    _applyFilters();
  }

  // Block or unblock a member
  Future<void> toggleBlockMember(client_model.Member member) async {
    final collection = member.memberType == "trainer" ? "trainers" : "clients";
    final updatedStatus = !member.isActive;
    final updatedExpiration = updatedStatus
        ? DateTime.now().add(Duration(days: 30))
        : null;

    await FirebaseFirestore.instance.collection(collection).doc(member.id).update({
      'isActive': updatedStatus,
      'membershipExpiration': updatedExpiration != null ? Timestamp.fromDate(updatedExpiration) : null,
    });

    int index = _allMembers.indexWhere((m) => m.id == member.id);
    if (index != -1) {
      _allMembers[index] = _allMembers[index].copyWith(
        isActive: updatedStatus,
        membershipExpiration: updatedExpiration,
      );
      _applyFilters();
    }
  }

  // Fetch member data by ID and update the local member list
  Future<Member?> fetchMemberById(String memberId, String memberType) async {
    try {
      final String collection = memberType; // Either 'clients' or 'trainers'

      // Fetch the member's document from Firestore
      final DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection(collection)
          .doc(memberId)
          .get();

      if (doc.exists) {
        // Map the document data to a Member object
        final Member updatedMember = Member.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );

        // Update the specific member in the _members list
        int index = _allMembers.indexWhere((m) => m.id == memberId);
        if (index != -1) {
          _allMembers[index] = updatedMember;
          notifyListeners(); // Notify listeners to update UI
        }

        return updatedMember; // Return the updated member
      } else {
        print("Member not found: $memberId");
        return null; // Return null if the document doesn't exist
      }
    } catch (e) {
      print("Error fetching updated member data: $e");
      return null; // Return null in case of an error
    }
  }
}
