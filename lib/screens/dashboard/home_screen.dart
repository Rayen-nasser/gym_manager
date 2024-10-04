import 'package:flutter/material.dart';
import '../../localization.dart';
import 'members_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function() onThemeChanged;
  final bool isDarkMode;

  const HomeScreen({
    super.key,
    required this.onThemeChanged,
    required this.isDarkMode,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const MembersScreen(),
    const Center(child: Text(
      "شاشة لوحة التحكم",
      style: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    )),
    const Center(child: Text(
      "شاشة التحصيل",
      style: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    )),
    const Center(child: Text(
      "شاشة صالة الألعاب الرياضية",
      style: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    )),
    const Center(child: Text(
      "تقرير اليوم",
      style: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    )),
  ];

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
          Localization.appName,
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
          double paddingFactor = isTablet ? 0.2 : 0.05;
          return Padding(
            padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth * paddingFactor
            ),
            child: _screens[_selectedIndex],
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
    );
  }
}