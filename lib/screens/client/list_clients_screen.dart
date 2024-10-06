import 'package:flutter/material.dart';
import 'package:gym_energy/screens/client/add_edit_client_screen.dart';
import 'package:gym_energy/model/client.dart' as client_model;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_energy/widgets/phone_cart_client_widget.dart';
import '../../localization.dart';
import '../../widgets/tablet_client_cart_widget.dart';
import 'package:gym_energy/model/sport.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({Key? key}) : super(key: key);

  @override
  _ClientsScreenState createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  String? _selectedSport;
  bool _showExpiredOnly = false;
  List<Sport> _sports = [];

  @override
  void initState() {
    super.initState();
    _fetchSports();
  }

  Future<void> _fetchSports() async {
    final sportSnapshot = await FirebaseFirestore.instance.collection('sports').get();
    setState(() {
      _sports = sportSnapshot.docs.map((doc) => Sport.fromMap(doc.data() as Map<String, dynamic>)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isTabletVertical = isTablet && screenSize.height > screenSize.width;

    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: FutureBuilder<List<client_model.Client>>(
              future: _fetchClients(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No clients or trainers found"));
                }

                final clients = _filterClients(snapshot.data!);

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isTablet ? (isTabletVertical ? 2 : 4) : 1,
                    childAspectRatio: isTablet ? (isTabletVertical ? 1.6 : 1.3) : 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: clients.length,
                  itemBuilder: (context, index) {
                    return isTablet
                        ? TabletClientCartWidget(client: clients[index])
                        : PhoneCartClientWidget(client: clients[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search by name',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              _buildFilterDropdown(),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildSportDropdown()),
              const SizedBox(width: 16),
              _buildExpiredCheckbox(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return DropdownButton<String>(
      value: _selectedFilter,
      icon: const Icon(Icons.filter_list),
      items: ['All', 'Clients', 'Trainers'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() => _selectedFilter = newValue!);
      },
    );
  }

  Widget _buildSportDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedSport,
      decoration: InputDecoration(
        labelText: 'Select Sport',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      icon: const Icon(Icons.sports),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('All Sports'),
        ),
        ..._sports.map((Sport sport) {
          return DropdownMenuItem<String>(
            value: sport.name,
            child: Text(sport.name),
          );
        }),
      ],
      onChanged: (String? newValue) {
        setState(() => _selectedSport = newValue);
      },
    );
  }

  Widget _buildExpiredCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _showExpiredOnly,
          onChanged: (bool? value) {
            setState(() => _showExpiredOnly = value ?? false);
          },
        ),
        const Text("Show Expired"),
      ],
    );
  }

  List<client_model.Client> _filterClients(List<client_model.Client> clients) {
    return clients.where((client) {
      final matchesFilter = _selectedFilter == 'All' ||
          (_selectedFilter == 'Clients' && client.clientIds == null) ||
          (_selectedFilter == 'Trainers' && client.clientIds != null);

      final matchesSport = _selectedSport == null ||
          client.sports.any((sport) => sport.name == _selectedSport);

      final matchesSearch = _searchQuery.isEmpty ||
          client.firstName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          client.lastName.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesExpiration = !_showExpiredOnly || !client.isActive;

      return matchesFilter && matchesSport && matchesSearch && matchesExpiration;
    }).toList();
  }

  Future<List<client_model.Client>> _fetchClients() async {
    final clientSnapshot = await FirebaseFirestore.instance.collection('clients').get();
    final trainerSnapshot = await FirebaseFirestore.instance.collection('trainers').get();

    final allDocs = [...clientSnapshot.docs, ...trainerSnapshot.docs];

    return allDocs.map((doc) => client_model.Client.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  void _navigateToAddClientScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddClientScreen()),
    );
  }
}