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

  final List<Widget> _screens = [
    const ClientsScreen(),
    _buildCenteredText("شاشة لوحة التحكم"),
    _buildCenteredText("شاشة التحصيل"),
    _buildCenteredText("شاشة صالة الألعاب الرياضية"),
    _buildCenteredText("تقرير اليوم"),
  ];

  final List<String> _titles = [
    'الأعضاء',
    'لوحة التحكم',
    'التحصيل',
    'جيم',
    'تقرير اليوم',
  ];

  static Widget _buildCenteredText(String text) {
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: theme.appBarTheme.titleTextStyle,
        ),
        actions: [
          IconButton(
            icon: Icon(
              widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: theme.appBarTheme.iconTheme?.color,
            ),
            onPressed: widget.onThemeChanged,
          ),
        ],
        toolbarHeight: isTablet ? 80 : 56,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double paddingFactor = isTablet ? 0.1 : 0.05;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: constraints.maxWidth * paddingFactor),
            child: _screens[_selectedIndex],
          );
        },
      ),
      drawer: Sidebar(
        onItemTapped: _onItemTapped,
        selectedIndex: _selectedIndex,
        title: 'قائمة التنقل', // Title for the sidebar
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
    );
  }
}
