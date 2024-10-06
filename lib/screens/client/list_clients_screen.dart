import 'package:flutter/material.dart';
import 'package:gym_energy/screens/client/add_edit_client_screen.dart';
import 'package:gym_energy/model/client.dart' as client_model;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_energy/widgets/phone_cart_client_widget.dart';
import '../../localization.dart';
import '../../widgets/side_bar.dart';
import '../../widgets/tablet_client_cart_widget.dart';
import 'package:gym_energy/model/sport.dart';

class ClientsScreen extends StatefulWidget {
  final String selectedFilter;
  final String? selectedSport;
  final bool showExpiredOnly;

  const ClientsScreen({
    Key? key,
    required this.selectedFilter,
    required this.selectedSport,
    required this.showExpiredOnly,
  }) : super(key: key);

  @override
  _ClientsScreenState createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  String _searchQuery = '';
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

    return Column(
      children: [
        _buildSearchBar(),
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
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        textDirection: TextDirection.rtl, // Set text direction to right-to-left
        decoration: InputDecoration(
          hintText: 'بحث عن اسم', // Arabic text for "Search by name"
          hintStyle: TextStyle(
            fontFamily: 'Cairo', // Ensure the Cairo font is applied
          ),
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        style: TextStyle(
          fontFamily: 'Cairo', // Apply the Cairo font for the input text
        ),
      ),
    );
  }

  List<client_model.Client> _filterClients(List<client_model.Client> clients) {
    return clients.where((client) {
      final matchesFilter = widget.selectedFilter == 'All' ||
          (widget.selectedFilter == 'Clients' && client.clientIds == null) ||
          (widget.selectedFilter == 'Trainers' && client.clientIds != null);

      final matchesSport = widget.selectedSport == null ||
          client.sports.any((sport) => sport.name == widget.selectedSport);

      final matchesSearch = _searchQuery.isEmpty ||
          client.firstName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          client.lastName.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesExpiration = !widget.showExpiredOnly || !client.isActive;

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
