import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/sport.dart';
import 'package:google_fonts/google_fonts.dart';

class Sidebar extends StatefulWidget {
  final String selectedFilter;
  final String? selectedSport;
  final bool showExpiredOnly;
  final Function(String) onFilterChanged;
  final Function(String?) onSportChanged;
  final Function(bool) onExpiredChanged;

  const Sidebar({
    Key? key,
    required this.selectedFilter,
    required this.selectedSport,
    required this.showExpiredOnly,
    required this.onFilterChanged,
    required this.onSportChanged,
    required this.onExpiredChanged,
  }) : super(key: key);

  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  List<Sport> _sports = [];
  bool _isLoading = true;
  String? _error;

  final Map<String, String> _filterOptions = {
    'All': 'الكل',
    'Clients': 'العملاء',
    'Trainers': 'المدربين'
  };

  @override
  void initState() {
    super.initState();
    _fetchSports();
  }

  Future<void> _fetchSports() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final sportSnapshot = await FirebaseFirestore.instance.collection('sports').get();

      final Set<String> uniqueSportNames = {};
      final List<Sport> uniqueSports = [];

      for (var doc in sportSnapshot.docs) {
        final sport = Sport.fromMap(doc.data() as Map<String, dynamic>);
        if (!uniqueSportNames.contains(sport.name)) {
          uniqueSportNames.add(sport.name);
          uniqueSports.add(sport);
        }
      }

      setState(() {
        _sports = uniqueSports;
        _isLoading = false;
      });

      if (widget.selectedSport != null &&
          !uniqueSportNames.contains(widget.selectedSport)) {
        widget.onSportChanged(null);
      }
    } catch (e) {
      setState(() {
        _error = 'فشل تحميل الرياضات: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Drawer(
        backgroundColor: theme.scaffoldBackgroundColor,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(
              "الفلاتر",
              style: GoogleFonts.cairo(
                textStyle: theme.textTheme.titleLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildFilterDropdown(theme),
            const SizedBox(height: 16),
            _buildSportSection(theme),
            const SizedBox(height: 16),
            _buildExpiredCheckbox(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: theme.primaryColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: widget.selectedFilter,
          icon: Icon(Icons.filter_list, color: theme.primaryColor),
          isExpanded: true,
          style: GoogleFonts.cairo(
            textStyle: theme.textTheme.bodyLarge,
            color: theme.textTheme.bodyLarge?.color,
          ),
          items: _filterOptions.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              widget.onFilterChanged(newValue);
            }
          },
        ),
      ),
    );
  }

  Widget _buildSportSection(ThemeData theme) {
    if (_isLoading) {
      return Container(
        height: 56, // Standard height for dropdown
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: theme.primaryColor),
        ),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: theme.colorScheme.error),
        ),
        child: Text(
          _error!,
          style: GoogleFonts.cairo(
            textStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ),
      );
    }

    return _buildSportDropdown(theme);
  }

  Widget _buildSportDropdown(ThemeData theme) {
    final currentValue = _sports.any((s) => s.name == widget.selectedSport)
        ? widget.selectedSport
        : null;

    return DropdownButtonFormField<String>(
      value: currentValue,
      decoration: InputDecoration(
        labelText: 'اختر الرياضة',
        labelStyle: GoogleFonts.cairo(
          textStyle: theme.textTheme.bodyLarge,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: theme.primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: theme.primaryColor, width: 2),
        ),
      ),
      icon: Icon(Icons.sports, color: theme.primaryColor),
      isExpanded: true,
      style: GoogleFonts.cairo(
        textStyle: theme.textTheme.bodyLarge,
        color: theme.textTheme.bodyLarge?.color,
      ),
      items: [
        DropdownMenuItem<String>(
          value: null,
          child: Text(
            'كل الرياضات',
            style: GoogleFonts.cairo(),
          ),
        ),
        ..._sports.map((Sport sport) {
          return DropdownMenuItem<String>(
            value: sport.name,
            child: Text(
              sport.name,
              style: GoogleFonts.cairo(),
            ),
          );
        }).toList(),
      ],
      onChanged: widget.onSportChanged,
    );
  }

  Widget _buildExpiredCheckbox(ThemeData theme) {
    return Row(
      children: [
        Checkbox(
          value: widget.showExpiredOnly,
          activeColor: theme.primaryColor,
          onChanged: (bool? value) {
            if (value != null) {
              widget.onExpiredChanged(value);
            }
          },
        ),
        Text(
          "إظهار المنتهية",
          style: GoogleFonts.cairo(
            textStyle: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}