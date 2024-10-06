import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final Function(int) onItemTapped;
  final int selectedIndex;
  final String title;

  const Sidebar({
    Key? key,
    required this.onItemTapped,
    required this.selectedIndex,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.primaryColor,
            ),
            child: Text(
              title, // Title for the drawer
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontFamily: 'Cairo',
              ),
            ),
          ),
          _buildListTile(context, Icons.people, 'الأعضاء', 0),
          _buildListTile(context, Icons.analytics, 'لوحة التحكم', 1),
          _buildListTile(context, Icons.account_balance_wallet, 'التحصيل', 2),
          _buildListTile(context, Icons.fitness_center, 'جيم', 3),
          _buildListTile(context, Icons.receipt, 'تقرير اليوم', 4),
        ],
      ),
    );
  }

  ListTile _buildListTile(BuildContext context, IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontFamily: 'Cairo')),
      onTap: () {
        onItemTapped(index); // Call the function passed from HomeScreen
        Navigator.pop(context); // Close the drawer
      },
      selected: selectedIndex == index, // Highlight the selected item
      selectedTileColor: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
    );
  }
}
