import 'package:flutter/material.dart';
import 'package:gym_energy/screens/client/add_edit_client_screen.dart';
import 'package:gym_energy/model/client.dart' as client_model;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../widgets/client_cart_widget.dart';

class ClientsScreen extends StatelessWidget {
  const ClientsScreen({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: FutureBuilder<List<client_model.Client>>(
          future: _fetchClients(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Fix the color of CircularProgressIndicator to use theme's onBackground color
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('خطأ: ${snapshot.error}',
                    style: const TextStyle(fontFamily: 'Cairo')),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text("لم يتم العثور على أي عملاء",
                    style: TextStyle(fontFamily: 'Cairo')),
              );
            }

            final clients = snapshot.data!;

            return Container(
              margin:  EdgeInsets.only(top: (isTablet ? 16 : 8), bottom:  (isTablet ? 16 : 8)), // Top and bottom margin
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isTablet ? 2 : 1,
                  childAspectRatio: isTablet ? 1.2 : 1,
                  crossAxisSpacing: isTablet ? 0 : 0, // Horizontal gap
                  mainAxisSpacing: isTablet ? 10 : 0,  // Vertical gap
                ),
                itemCount: clients.length,
                itemBuilder: (context, index) {
                  return ClientCartWidget(
                    client: clients[index],
                  );
                },
              ),
            );
          },
        ),
      ),

      // FloatingActionButton positioned on the left
      floatingActionButton:
           FloatingActionButton(
        onPressed: () => _navigateToAddClientScreen(context),
        child: const Icon(Icons.add),
        tooltip: 'إضافة عضو جديد',
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat, // Positioned on the left
    );
  }

  Future<List<client_model.Client>> _fetchClients() async {
    final clientSnapshot = await FirebaseFirestore.instance.collection('clients').get();
    final trainerSnapshot = await FirebaseFirestore.instance.collection('trainers').get();

    final allDocs = [...clientSnapshot.docs, ...trainerSnapshot.docs];

    return allDocs.map((doc) {
      return client_model.Client.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

  void _navigateToAddClientScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddClientScreen()),
    );
  }
}