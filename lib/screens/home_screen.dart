import 'package:flutter/material.dart';
import 'package:gym_energy/screens/daily_report/daily_report_screen.dart';
import 'package:gym_energy/screens/gym/gym_screen.dart';
import 'package:gym_energy/screens/members/add_edit_member_screen.dart';
import 'package:gym_energy/screens/members/list_members_screen.dart';
import 'package:workmanager/workmanager.dart';
import '../widgets/side_bar.dart';

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

  // Method to dynamically change the AppBar title
  String get _appTitle {
    switch (_selectedIndex) {
      case 0:
        return 'الأعضاء';
      case 1:
        return 'معلومات الجيم';
      case 2:
        return 'تحليلات النادي الرياضي';
      default:
        return 'Gym Energy';
    }
  }

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
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Method to load data (e.g., refresh action in the AppBar)
  void _loadData() {
    // Add your logic for refreshing data
    print('Refreshing data...');
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
            _appTitle,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
              color: theme.appBarTheme.foregroundColor ?? theme.colorScheme.onPrimary,
            ),
          ),
          backgroundColor: theme.appBarTheme.backgroundColor ?? theme.primaryColor,
          elevation: 0,
          actions: _selectedIndex == 0
              ? [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddEditMemberScreen()),
                );
              },
              tooltip: 'Add Client',
              color: Colors.white,
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
          backgroundColor: theme.colorScheme.primary,
          selectedItemColor: theme.colorScheme.secondary,
          unselectedItemColor: Colors.white,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          iconSize: isTablet ? 36 : 24,
          selectedLabelStyle: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.secondary,
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
