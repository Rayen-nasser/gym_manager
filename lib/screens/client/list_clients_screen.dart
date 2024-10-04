import 'package:flutter/material.dart';
import 'package:gym_energy/screens/client/add_edit_client_screen.dart';
import 'package:gym_energy/widgets/client_cart_widget.dart';
import 'package:gym_energy/model/client.dart' as client_model;


class ClientsScreen extends StatelessWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample member data
    // Sample client data
    final List<client_model.Client> clients = [
      // Client(
      //   id: '1',
      //   firstName: 'علي',
      //   lastName: 'أحمد',
      //   email: 'ali@example.com',
      //   phoneNumber: '0123456789',
      //   membershipExpiration: DateTime.now().add(Duration(days: 30)), sports: [], // 30 days from now
      //   totalPaid: 500
      // ),
      // Client(
      //   id: '2',
      //   firstName: 'فاطمة',
      //   lastName: 'محمد',
      //   email: 'fatima@example.com',
      //   phoneNumber: '9876543210',
      //   membershipExpiration: DateTime.now().add(Duration(days: 60)), sports: [], createdAt: null, // 60 days from now
      //   totalPaid: 150
      // ),
      // // Add more Client instances as needed
    ];

    // Determine screen width
    final screenWidth = MediaQuery.of(context).size.width;
    bool isTablet = screenWidth > 600;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12,),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isTablet ? 3 : 1, // 4 items in a row for tablets, 2 for phones
                  childAspectRatio: isTablet ? 1.1 : 1.3, // Adjust aspect ratio as needed
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: clients.length,
                itemBuilder: (context, index) {
                  return MemberCartWidget(client: clients[index], totalPaid: clients[index].totalPaid,);
                },
              ),
            ),
          ],
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

}
