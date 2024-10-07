import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_energy/model/member.dart' as client_model;

class MembersProvider with ChangeNotifier {
  List<client_model.Member> _allMembers = [];
  List<client_model.Member> _filteredMembers = [];

  String _searchQuery = '';
  String selectedFilter = 'All';
  String? selectedSport;
  bool showExpiredOnly = false;
  bool showActiveMembers = true;

  List<client_model.Member> get filteredMembers => _filteredMembers;

  Future<void> fetchMembers() async {
    final clientSnapshot = await FirebaseFirestore.instance.collection('clients').get();
    final trainerSnapshot = await FirebaseFirestore.instance.collection('trainers').get();

    final allDocs = [...clientSnapshot.docs, ...trainerSnapshot.docs];

    _allMembers = allDocs
        .map((doc) => client_model.Member.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();

    _applyFilters();
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

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

  void _applyFilters() {
    _filteredMembers = _allMembers.where((client) {
      final matchesFilter = selectedFilter == 'All' ||
          (selectedFilter == 'Clients' && client.memberType == "trainee") ||
          (selectedFilter == 'Trainers' && client.memberType == "trainer");

      final matchesSport = selectedSport == null ||
          client.sports.any((sport) => sport.name == selectedSport);

      final matchesSearch = _searchQuery.isEmpty ||
          client.firstName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          client.lastName.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesExpiration = !showExpiredOnly || !client.isExpirationActive;

      final matchesActiveStatus = showActiveMembers ? client.isActive : !client.isActive;

      return matchesFilter && matchesSport && matchesSearch && matchesExpiration && matchesActiveStatus;
    }).toList();

    notifyListeners();
  }

  Future<void> editMember(client_model.Member updatedMember) async {
    final collection = updatedMember.memberType == "trainer" ? "trainers" : "clients";
    await FirebaseFirestore.instance.collection(collection).doc(updatedMember.id).update(updatedMember.toMap());

    int index = _allMembers.indexWhere((member) => member.id == updatedMember.id);
    if (index != -1) {
      _allMembers[index] = updatedMember;
      _applyFilters();
    }
  }

  Future<void> deleteMember(client_model.Member member) async {
    final collection = member.memberType == "trainer" ? "trainers" : "clients";
    await FirebaseFirestore.instance.collection(collection).doc(member.id).delete();

    _allMembers.removeWhere((m) => m.id == member.id);
    _applyFilters();
  }

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
}