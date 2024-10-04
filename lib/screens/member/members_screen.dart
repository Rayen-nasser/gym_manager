import 'package:flutter/material.dart';
import 'package:gym_energy/widgets/member_cart_widget.dart';

import '../../model/client.dart';

class MembersScreen extends StatelessWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample member data
    // Sample client data
    final List<Client> clients = [
      Client(
        id: '1',
        firstName: 'علي',
        lastName: 'أحمد',
        email: 'ali@example.com',
        phoneNumber: '0123456789',
        membershipExpiration: DateTime.now().add(Duration(days: 30)), sports: [], // 30 days from now
        totalPaid: 500
      ),
      Client(
        id: '2',
        firstName: 'فاطمة',
        lastName: 'محمد',
        email: 'fatima@example.com',
        phoneNumber: '9876543210',
        membershipExpiration: DateTime.now().add(Duration(days: 60)), sports: [], createdAt: null, // 60 days from now
        totalPaid: 150
      ),
      // Add more Client instances as needed
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
                  return MemberCartWidget(client: clients[index], totalPaid: clients[index].totalPaid!,);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Logic to add a new member
          _showAddMemberDialog(context);
        },
        child: const Icon(Icons.add),
        tooltip: 'إضافة عضو جديد',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  void _showAddMemberDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('إضافة عضو جديد'),
          content: TextField(
            decoration: const InputDecoration(hintText: 'اسم العضو'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                // Handle adding the member here
                Navigator.of(context).pop();
              },
              child: const Text('إضافة'),
            ),
          ],
        );
      },
    );
  }
}
