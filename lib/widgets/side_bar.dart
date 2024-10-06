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
  final Function(bool) onActiveMembersChanged;

  const Sidebar({
    Key? key,
    required this.selectedFilter,
    required this.selectedSport,
    required this.showExpiredOnly,
    required this.onFilterChanged,
    required this.onSportChanged,
    required this.onActiveMembersChanged,
    required this.onExpiredChanged,
  }) : super(key: key);

  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  List<Sport> _sports = [];
  bool _isLoading = true;
  String? _error;
  bool _showActiveMembers = true;

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

      if (widget.selectedSport != null && !uniqueSportNames.contains(widget.selectedSport)) {
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "الفلاتر",
                  style: GoogleFonts.cairo(
                    textStyle: theme.textTheme.headlineSmall,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 24),
                _buildFilterDropdown(theme),
                const SizedBox(height: 24),
                _buildSportSection(theme),
                const SizedBox(height: 24),
                _buildExpiredCheckbox(theme),
                const SizedBox(height: 24),
                _buildToggleButtons(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(ThemeData theme) {
    return DropdownButtonFormField<String>(
      value: widget.selectedFilter,
      decoration: _getInputDecoration(theme, 'اختر الفئة'),
      icon: Icon(Icons.filter_list, color: theme.primaryColor),
      isExpanded: true,
      style: _getTextStyle(theme),
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
    );
  }

  Widget _buildSportSection(ThemeData theme) {
    if (_isLoading) {
      return _buildLoadingIndicator(theme);
    }
    if (_error != null) {
      return _buildErrorMessage(theme);
    }
    return _buildSportDropdown(theme);
  }

  Widget _buildLoadingIndicator(ThemeData theme) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
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

  Widget _buildErrorMessage(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
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

  Widget _buildSportDropdown(ThemeData theme) {
    final currentValue = _sports.any((s) => s.name == widget.selectedSport)
        ? widget.selectedSport
        : null;

    return DropdownButtonFormField<String>(
      value: currentValue,
      decoration: _getInputDecoration(theme, 'اختر الرياضة'),
      icon: Icon(Icons.sports, color: theme.primaryColor),
      isExpanded: true,
      style: _getTextStyle(theme),
      items: [
        DropdownMenuItem<String>(
          value: null,
          child: Text('كل الرياضات', style: GoogleFonts.cairo()),
        ),
        ..._sports.map((Sport sport) {
          return DropdownMenuItem<String>(
            value: sport.name,
            child: Text(sport.name, style: GoogleFonts.cairo()),
          );
        }).toList(),
      ],
      onChanged: widget.onSportChanged,
    );
  }

  Widget _buildToggleButtons(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.primaryColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton(
              theme,
              "نشط",
              _showActiveMembers,
                  () => _toggleActiveStatus(true),
            ),
          ),
          Expanded(
            child: _buildToggleButton(
              theme,
              "غير نشط",
              !_showActiveMembers,
                  () => _toggleActiveStatus(false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(ThemeData theme, String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.cairo(
              textStyle: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : theme.primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _toggleActiveStatus(bool isActive) {
    setState(() {
      _showActiveMembers = isActive;
      widget.onActiveMembersChanged(isActive);
    });
  }

  Widget _buildExpiredCheckbox(ThemeData theme) {
    return Row(
      children: [
        Checkbox(
          value: widget.showExpiredOnly,
          activeColor: theme.primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          onChanged: (bool? value) {
            if (value != null) {
              widget.onExpiredChanged(value);
            }
          },
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => widget.onExpiredChanged(!widget.showExpiredOnly),
            child: Text(
              "إظهار المنتهية اشتراكاتهم",
              style: GoogleFonts.cairo(
                  textStyle: theme.textTheme.bodyMedium,
                  fontSize: 14,
                  fontWeight: FontWeight.w500
              ),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _getInputDecoration(ThemeData theme, String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.cairo(
        textStyle: theme.textTheme.bodyLarge,
        color: theme.primaryColor,
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.primaryColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.primaryColor, width: 2),
      ),
      filled: true,
      fillColor: theme.cardColor,
    );
  }

  TextStyle _getTextStyle(ThemeData theme) {
    return GoogleFonts.cairo(
      textStyle: theme.textTheme.bodyLarge,
      color: theme.textTheme.bodyLarge?.color,
    );
  }
}