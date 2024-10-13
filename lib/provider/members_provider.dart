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
  bool _isLoading = false;

  // Getter for loading state
  bool get isLoading => _isLoading;

  // Getter for filtered members
  List<client_model.Member> get filteredMembers => _filteredMembers;

  // Getter for sports
  List<Sport> get availableSports => _sports;

  // Fetch all members (both clients and trainers) from Firestore
  // Modify fetchMembers to set loading state
  Future<void> fetchMembers() async {
    _isLoading = true; // Set loading state to true
    notifyListeners(); // Notify listeners to update UI

    try {
      final clientSnapshot = await FirebaseFirestore.instance.collection('clients').get();
      final trainerSnapshot = await FirebaseFirestore.instance.collection('trainers').get();

      _allMembers = [
        ...clientSnapshot.docs.map((doc) => client_model.Member.fromMap(doc.data() as Map<String, dynamic>, doc.id)),
        ...trainerSnapshot.docs.map((doc) => client_model.Member.fromMap(doc.data() as Map<String, dynamic>, doc.id)),
      ];

      _applyFilters();
    } finally {
      _isLoading = false; // Set loading state to false after fetching
      notifyListeners(); // Notify listeners to update UI
    }
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

  // Add member details
  Future<void> addMember(client_model.Member updatedMember) async {
   _allMembers.add(updatedMember);
   _applyFilters();
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

// Renewing membership and handling unpaid months
  // Renewing membership, handling multiple unpaid months
  Future<Member> renewMembership(Member member) async {
    try {
      DateTime now = DateTime.now();

      // Calculate the number of unpaid months (if any) based on membership expiration
      int unpaidMonthsCount = 0;
      if (member.membershipExpiration.isBefore(now)) {
        // Calculate the number of months between expiration and now
        final diffInDays = now.difference(member.membershipExpiration).inDays;
        unpaidMonthsCount = (diffInDays / 30).ceil(); // Each "month" is considered 30 days
      }

      // Calculate the new expiration date based on unpaid months
      DateTime newExpirationDate = now.add(Duration(days: 30 * (unpaidMonthsCount + 1)));
      // Add one month to the current date, considering any unpaid months

      // Calculate the renewal fee for all unpaid months
      double renewalFee = member.totalSportPrices() * (unpaidMonthsCount + 1); // Including current month

      // Update Firestore with the new expiration date and payment details
      await FirebaseFirestore.instance
          .collection('${member.memberType}s')
          .doc(member.id)
          .update({
        'membershipExpiration': Timestamp.fromDate(newExpirationDate),
        'paymentDates': FieldValue.arrayUnion([Timestamp.fromDate(DateTime.now())]), // Add current payment date
        'totalPaid': FieldValue.increment(renewalFee), // Increment by the renewal fee
      });

      // Update local member data
      int index = _allMembers.indexWhere((m) => m.id == member.id);
      if (index != -1) {
        // Update the local member object with new expiration and payment details
        Member updatedMember = _allMembers[index].copyWith(
          membershipExpiration: newExpirationDate,
          paymentDates: [..._allMembers[index].paymentDates, DateTime.now()],
          totalPaid: _allMembers[index].totalPaid + renewalFee, // Increment total paid
        );

        _allMembers[index] = updatedMember; // Update the member in the list
        _applyFilters(); // Reapply filters to refresh the member list
        notifyListeners(); // Notify listeners of the changes

        return updatedMember; // Return the updated member
      }

      throw Exception('Member not found');
    } catch (e) {
      print("Error renewing membership: $e");
      throw e;
    }
  }

  // New method for update price sport
  Future<void> updateMemberSportPrices(Sport updatedSport) async {
    try {
      // Create a map of sports with the updated price
      final updatedSports = {
        updatedSport.id: updatedSport.price,
      };

      // Create a batch for Firestore updates
      final WriteBatch batch = FirebaseFirestore.instance.batch();

      // Iterate through each member and prepare batch updates
      for (client_model.Member member in _allMembers) {
        // Convert to your Member model if necessary
        final data = Member.fromMap(member.toMap(), member.id); // Ensure you have a method to convert your model

        // Update the sports list to reflect the new price
        final updatedMemberSports = data.sports.map((sport) {
          if (sport.id == updatedSport.id) {
            // Update the price of the matching sport
            return sport.copyWith(price: updatedSport.price);
          }
          return sport;
        }).toList();

        // Prepare the update for Firestore
        batch.update(
          FirebaseFirestore.instance.collection('${member.memberType}s').doc(member.id),
          {
            'sports': updatedMemberSports.map((sport) => sport.toMap()).toList(),
          },
        );
      }

      // Commit all updates in a single batch
      await batch.commit();

      // Refresh members after updating prices
      await fetchMembers(); // Refresh the list after the update
    } catch (e) {
      print('Error updating member sport prices: $e');
    }
  }

  // New method to check for existing members locally
  bool memberExists({required String firstName, required String lastName, String? id}) {
    return _allMembers.any((member) =>
    member.firstName.toLowerCase() == firstName.toLowerCase() &&
        member.lastName.toLowerCase() == lastName.toLowerCase()); // Exclude the current member when editing
  }

  // New method to check for existing email locally
  bool emailExists(String email, {String? excludeId}) {
    return _allMembers.any((member) =>
    member.email?.toLowerCase() == email.toLowerCase() &&
        member.id != excludeId);
  }

  // New method to check for existing phone number locally
  bool phoneNumberExists(String phoneNumber, {String? excludeId}) {
    return _allMembers.any((member) =>
    member.phoneNumber == phoneNumber &&
        member.id != excludeId);
  }

}
