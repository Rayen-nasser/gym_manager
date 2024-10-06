import 'package:flutter/material.dart';
import 'package:gym_energy/screens/client/add_edit_client_screen.dart';
import 'package:gym_energy/screens/client/list_clients_screen.dart';
import '../widgets/side_bar.dart';
import '../localization.dart';

class HomeScreen extends StatefulWidget {
  final Function() onThemeChanged;
  final bool isDarkMode;

  const HomeScreen({
    Key? key,
    required this.onThemeChanged,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _selectedFilter = 'All';
  String? _selectedSport;
  bool _showExpiredOnly = false;

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return ClientsScreen(
          selectedFilter: _selectedFilter,
          selectedSport: _selectedSport,
          showExpiredOnly: _showExpiredOnly,
        );
      case 1:
        return _buildCenteredText("شاشة لوحة التحكم");
      case 2:
        return _buildCenteredText("شاشة التحصيل");
      case 3:
        return _buildCenteredText("شاشة صالة الألعاب الرياضية");
      case 4:
        return _buildCenteredText("تقرير اليوم");
      default:
        return _buildCenteredText("الشاشة غير موجودة");
    }
  }

  Widget _buildCenteredText(String text) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    bool isTablet = screenWidth > 600;
    final theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _selectedIndex == 0 ? 'العملاء' : 'Gym Energy',
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          leading: _selectedIndex == 0
              ? Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          )
              : null,
          // Add an IconButton for the "Add Client" action
          actions: _selectedIndex == 0
              ? [
            IconButton(
              icon: const Icon(Icons.add), // Plus icon to indicate adding a new client
              tooltip: 'Add Client',
              onPressed: () {
                // Action to navigate to Add Client Screen or open a dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddClientScreen()),
                );
              },
            ),
          ]
              : [],
        ),
        drawer: _selectedIndex == 0
            ? Sidebar(
          selectedFilter: _selectedFilter,
          selectedSport: _selectedSport,
          showExpiredOnly: _showExpiredOnly,
          onFilterChanged: (filter) {
            setState(() {
              _selectedFilter = filter;
            });
          },
          onSportChanged: (sport) {
            setState(() {
              _selectedSport = sport;
            });
          },
          onExpiredChanged: (value) {
            setState(() {
              _showExpiredOnly = value;
            });
          },
        )
            : null,
        body: LayoutBuilder(
          builder: (context, constraints) {
            double paddingFactor = isTablet ? 0.1 : 0.05;
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth * paddingFactor,
              ),
              child: _getScreen(_selectedIndex),
            );
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: theme.primaryColor,
          selectedItemColor: theme.colorScheme.secondary,
          unselectedItemColor: Colors.white,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          iconSize: isTablet ? 36 : 24,
          selectedLabelStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Cairo',
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'الأعضاء',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics),
              label: 'لوحة التحكم',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet),
              label: 'التحصيل',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center),
              label: 'جيم',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt),
              label: 'تقرير اليوم',
            ),
          ],
        ),
      ),
    );
  }
}