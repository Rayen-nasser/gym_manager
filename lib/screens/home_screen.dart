import 'package:flutter/material.dart';
import 'package:gym_energy/screens/daily_report/daily_report_screen.dart';
import 'package:gym_energy/screens/gym/gym_screen.dart';
import 'package:gym_energy/screens/members/add_edit_member_screen.dart';
import 'package:gym_energy/screens/members/list_members_screen.dart';
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
  bool _showActiveMembers = true;

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return MembersScreen(
          selectedFilter: _selectedFilter,
          selectedSport: _selectedSport,
          showExpiredOnly: _showExpiredOnly,
          showActiveMembers: _showActiveMembers,
        );
      case 1:
        return GymScreen();
      case 2:
        return GymAnalyticsDashboard();
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
        appBar: _selectedIndex == 1
            ? AppBar(
          title: const Text(
            'معلومات الجيم',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).primaryColor,
        )
            : AppBar(
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
          actions: _selectedIndex == 0
              ? [
            IconButton(
              icon: const Icon(Icons.add), // Plus icon to indicate adding a new client
              tooltip: 'Add Client',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddEditMemberScreen()),
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
          selectActiveMember: _showActiveMembers,
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
          onActiveMembersChanged: (value) {
            setState(() {
              _showActiveMembers = value; // Update active/inactive state
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
