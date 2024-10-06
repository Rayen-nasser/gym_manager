import 'package:flutter/material.dart';
import 'package:gym_energy/model/member.dart' as client_model;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_energy/widgets/phone_cart_client_widget.dart';
import 'client_detail_screen.dart';
import '../../widgets/tablet_client_cart_widget.dart';


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

  @override
  void initState() {
    super.initState();
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
          child: FutureBuilder<List<client_model.Member>>(
            future: _fetchClients(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("لم يتم العثور على عملاء أو مدربين"));
              }

              final clients = _filterClients(snapshot.data!);

              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isTablet ? (isTabletVertical ? 2 : 4) : 1,
                  childAspectRatio: isTablet ? (isTabletVertical ? 1.6 : 1.3) : 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 6,
                ),
                itemCount: clients.length,
                itemBuilder: (context, index) {
                  final client = clients[index]; // Get the client object

                  return GestureDetector(
                    onTap: () {
                      print('Card tapped: ${client.firstName}'); // Debugging line
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClientDetailScreen(client: client),
                        ),
                      );
                    },
                    child: isTablet
                        ? TabletClientCartWidget(client: client) // Your actual widget
                        : PhoneCartClientWidget(client: client), // Your actual widget
                  );
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
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        textDirection: TextDirection.rtl, // Set text direction to right-to-left
        decoration: InputDecoration(
          hintText: 'بحث عن اسم أو اللقب', // Arabic text for "Search by name"
          hintStyle: TextStyle(
            fontFamily: 'Cairo', // Apply Cairo font
            color: Theme.of(context).primaryColor, // Use the primary color for hint text
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

  List<client_model.Member> _filterClients(List<client_model.Member> clients) {
    return clients.where((client) {
      final matchesFilter = widget.selectedFilter == 'All' ||
          (widget.selectedFilter == 'Clients' && client.memberType == "trainee") ||
          (widget.selectedFilter == 'Trainers' && client.memberType == "trainer");

      final matchesSport = widget.selectedSport == null ||
          client.sports.any((sport) => sport.name == widget.selectedSport);

      final matchesSearch = _searchQuery.isEmpty ||
          client.firstName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          client.lastName.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesExpiration = !widget.showExpiredOnly || !client.isExpirationActive;

      // Add filtering for active and inactive members
      final matchesActiveStatus = widget.showActiveMembers ? client.isActive : !client.isActive;

      return matchesFilter && matchesSport && matchesSearch && matchesExpiration;
    }).toList();
  }

  Future<List<client_model.Member>> _fetchClients() async {
    final clientSnapshot = await FirebaseFirestore.instance.collection('clients').get();
    final trainerSnapshot = await FirebaseFirestore.instance.collection('trainers').get();

    final allDocs = [...clientSnapshot.docs, ...trainerSnapshot.docs];

    return allDocs.map((doc) => client_model.Member.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }
}
