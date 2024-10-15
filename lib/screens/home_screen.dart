import 'package:flutter/material.dart';
import 'package:gym_energy/model/user.dart';
import 'package:gym_energy/screens/auth/login.dart';
import 'package:gym_energy/screens/daily_report/daily_report_screen.dart';
import 'package:gym_energy/screens/gym/gym_screen.dart';
import 'package:gym_energy/screens/members/add_edit_member_screen.dart';
import 'package:gym_energy/screens/members/list_members_screen.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase sign-out functionality
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore for user roles

import '../widgets/side_bar.dart';

class HomeScreen extends StatefulWidget {
  final Function()? onThemeChanged;
  final bool? isDarkMode;

  const HomeScreen({
    Key? key,
    this.onThemeChanged,
    this.isDarkMode,
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
  bool isAdmin = false; // Variable to check if the user is an admin

  @override
  void initState() {
    super.initState();
    _checkAdminPrivileges();
  }

  // Method to check if the user is an admin
  void _checkAdminPrivileges() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
        if (userDoc.exists) { // Ensure the document exists
          // Check if the widget is still mounted before calling setState
          if (mounted) {
            UserModel user = UserModel.fromMap(userDoc.data()!, userDoc.id); // Use userDoc.data() safely
            setState(() {
              isAdmin = user.isAdmin(); // Assuming you store user role
            });
          }
        } else {
          // Handle the case where the user document doesn't exist
          if (mounted) {
            setState(() {
              isAdmin = false; // or handle it as you see fit
            });
          }
        }
      } catch (e) {
        // Handle errors appropriately (e.g., log them, show a message)
        print('Error fetching user data: $e');
        if (mounted) {
          setState(() {
            isAdmin = false; // or handle as appropriate
          });
        }
      }
    }
  }

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

  // Sign out method
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginScreen())); // Replace with your login screen route
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
        return GymAnalyticsDashboard(); // Ensure this is your correct daily report screen
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
          actions: _selectedIndex == 1 || _selectedIndex == 2 // Gym and Daily Report screens
              ? [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: _signOut,
              tooltip: 'Sign Out',
              color: Colors.white,
            ),
          ]
              : _selectedIndex == 0
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
              _showActiveMembers = value;
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
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'الأعضاء',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center),
              label: 'جيم',
            ),
            if (isAdmin) // Show Daily Report only if user is admin
              const BottomNavigationBarItem(
                icon: Icon(Icons.receipt),
                label: 'تقرير اليوم',
              ),
          ],
        ),
      ),
    );
  }
}
