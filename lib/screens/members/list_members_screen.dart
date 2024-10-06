import 'package:flutter/material.dart';
import 'package:gym_energy/model/member.dart' as client_model;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_energy/widgets/phone_cart_member_widget.dart';
import 'member_detail_screen.dart';
import '../../widgets/tablet_members_cart_widget.dart';

class ClientsScreen extends StatefulWidget {
  final String selectedFilter;
  final String? selectedSport;
  final bool showExpiredOnly;
  final bool showActiveMembers;

  const ClientsScreen({
    Key? key,
    required this.selectedFilter,
    required this.selectedSport,
    required this.showExpiredOnly,
    this.showActiveMembers = true,
  }) : super(key: key);

  @override
  _ClientsScreenState createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  String _searchQuery = '';
  List<client_model.Member> _allMembers = [];
  List<client_model.Member> _filteredMembers = [];

  @override
  void initState() {
    super.initState();
    _fetchClients();
  }

  @override
  void didUpdateWidget(ClientsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedFilter != widget.selectedFilter ||
        oldWidget.selectedSport != widget.selectedSport ||
        oldWidget.showExpiredOnly != widget.showExpiredOnly ||
        oldWidget.showActiveMembers != widget.showActiveMembers) {
      _applyFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isTabletVertical = isTablet && screenSize.height > screenSize.width;

    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: _allMembers.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isTablet ? (isTabletVertical ? 2 : 4) : 1,
              childAspectRatio: isTablet ? (isTabletVertical ? 1.6 : 1.3) : 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 6,
            ),
            itemCount: _filteredMembers.length,
            itemBuilder: (context, index) {
              final client = _filteredMembers[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClientDetailScreen(client: client),
                    ),
                  );
                },
                child: isTablet
                    ? TabletClientCartWidget(client: client)
                    : PhoneCartClientWidget(client: client),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: TextField(
        onChanged: (value) {
          setState(() => _searchQuery = value);
          _applyFilters();
        },
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: 'بحث عن اسم أو اللقب',
          hintStyle: TextStyle(
            fontFamily: 'Cairo',
            color: Theme.of(context).primaryColor,
          ),
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        style: TextStyle(
            fontFamily: 'Cairo',
            color: Theme.of(context).colorScheme.primary
        ),
      ),
    );
  }

  void _applyFilters() {
    _filteredMembers = _allMembers.where((client) {
      final matchesFilter = widget.selectedFilter == 'All' ||
          (widget.selectedFilter == 'Clients' && client.memberType == "trainee") ||
          (widget.selectedFilter == 'Trainers' && client.memberType == "trainer");

      final matchesSport = widget.selectedSport == null ||
          client.sports.any((sport) => sport.name == widget.selectedSport);

      final matchesSearch = _searchQuery.isEmpty ||
          client.firstName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          client.lastName.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesExpiration = !widget.showExpiredOnly || !client.isExpirationActive;

      final matchesActiveStatus = widget.showActiveMembers ? client.isActive : !client.isActive;

      return matchesFilter && matchesSport && matchesSearch && matchesExpiration && matchesActiveStatus;
    }).toList();

    setState(() {});
  }

  Future<void> _fetchClients() async {
    final clientSnapshot = await FirebaseFirestore.instance.collection('clients').get();
    final trainerSnapshot = await FirebaseFirestore.instance.collection('trainers').get();

    final allDocs = [...clientSnapshot.docs, ...trainerSnapshot.docs];

    _allMembers = allDocs.map((doc) => client_model.Member.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    _applyFilters();
  }
}