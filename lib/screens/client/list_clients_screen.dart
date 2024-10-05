import 'package:flutter/material.dart';
import 'package:gym_energy/screens/client/add_edit_client_screen.dart';
import 'package:gym_energy/widgets/client_cart_widget.dart';
import 'package:gym_energy/model/client.dart' as client_model; // Import your client model
import 'package:cloud_firestore/cloud_firestore.dart';

class ClientsScreen extends StatelessWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine screen width
    final screenWidth = MediaQuery.of(context).size.width;
    bool isTablet = screenWidth > 600;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: FutureBuilder<List<client_model.Client>>(
          future: _fetchClients(), // Fetch clients from Firestore
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator()); // Loading state
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}')); // Error state
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text("لم يتم العثور على أي عملاء")); // No data state
            }

            final clients = snapshot.data!; // Get the clients list

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isTablet ? 3 : 1, // 3 items in a row for tablets, 1 for phones
                childAspectRatio: isTablet ? 1.1 : 1.3, // Adjust aspect ratio as needed
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: clients.length,
              itemBuilder: (context, index) {
                return ClientCartWidget(
                  client: clients[index],
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddClientScreen()),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'إضافة عضو جديد',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  Future<List<client_model.Client>> _fetchClients() async {
    final snapshot = await FirebaseFirestore.instance.collection('clients').get();
    return snapshot.docs.map((doc) {
      // Use fromMap to convert Firestore document to Client instance
      return client_model.Client.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }
}
