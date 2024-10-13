import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gym_energy/widgets/phone_cart_member_widget.dart';
import 'package:gym_energy/widgets/tablet_members_cart_widget.dart';
import '../../provider/members_provider.dart';
import 'member_detail_screen.dart';

class MembersScreen extends StatefulWidget {
  final String selectedFilter;
  final String? selectedSport;
  final bool showExpiredOnly;
  final bool showActiveMembers;

  const MembersScreen({
    Key? key,
    required this.selectedFilter,
    required this.selectedSport,
    required this.showExpiredOnly,
    this.showActiveMembers = true,
  }) : super(key: key);

  @override
  _MembersScreenState createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {

  @override
  void didUpdateWidget(MembersScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_hasFiltersChanged(oldWidget)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = Provider.of<MembersProvider>(context, listen: false);
        _updateFilters(provider);
      });
    }
  }

  bool _hasFiltersChanged(MembersScreen oldWidget) {
    return oldWidget.selectedFilter != widget.selectedFilter ||
        oldWidget.selectedSport != widget.selectedSport ||
        oldWidget.showExpiredOnly != widget.showExpiredOnly ||
        oldWidget.showActiveMembers != widget.showActiveMembers;
  }

  void _updateFilters(MembersProvider provider) {
    provider.updateFilters(
      filter: widget.selectedFilter,
      sport: widget.selectedSport,
      expiredOnly: widget.showExpiredOnly,
      activeMembers: widget.showActiveMembers,
    );
  }

  @override
  Widget build(BuildContext context) {

    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isTabletVertical = isTablet && screenSize.height > screenSize.width;

    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: Consumer<MembersProvider>(
            builder: (context, provider, _) {
              final filteredMembers = provider.filteredMembers;
              final isLoading = provider.isLoading;

              if (isLoading) {
                // Show loading indicator
                return const Center(child: CircularProgressIndicator());
              }

              if (filteredMembers.isEmpty) {
                return Center(
                  child: _buildEmptyMessage(provider), // Call to the method that builds the message
                );
              }
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isTablet ? (isTabletVertical ? 2 : 4) : 1,
                  childAspectRatio: isTablet ? (isTabletVertical ? 1.6 : 1.3) : 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 6,
                ),
                itemCount: filteredMembers.length,
                itemBuilder: (context, index) {
                  final member = filteredMembers[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MemberDetailScreen(
                            memberId: member.id,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      color: Colors.transparent, // Set a background color to check for touchability
                      child: isTablet
                          ? TabletClientCartWidget(member: member)
                          : PhoneCartClientWidget(member: member),
                    ),
                  )

                  ;
                },
              );
            },
          ),
        ),
      ],
    );
  }

// Method to build the empty message based on current filters
  Widget _buildEmptyMessage(MembersProvider provider) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.info, size: 48, color: Colors.grey),
        const SizedBox(height: 16),
        Text(
          'لا يوجد أعضاء مطابقون للمعايير المحددة',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _getFilterDetails(provider),
          style: TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

// Method to generate filter details message
  String _getFilterDetails(MembersProvider provider) {
    List<String> details = [];

    if (provider.selectedFilter != 'All') {
      details.add('نوع العضو: ${provider.selectedFilter}');
    }
    if (provider.selectedSport != null) {
      details.add('الرياضة: ${provider.selectedSport}');
    }
    if (provider.showExpiredOnly) {
      details.add('عرض الأعضاء المنتهية صلاحيتهم فقط');
    }
    if (!provider.showActiveMembers) {
      details.add('عرض الأعضاء غير النشطين');
    }

    return details.isEmpty ? 'يرجى تعديل المعايير.' : details.join('\n');
  }


  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: TextField(
        onChanged: (value) {
          Provider.of<MembersProvider>(context, listen: false).updateSearchQuery(value);
        },
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: 'بحث عن اسم أو اللقب',
          hintStyle: TextStyle(
            fontFamily: 'Cairo',
            color: Theme.of(context).primaryColor,
          ),
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        style: TextStyle(
          fontFamily: 'Cairo',
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}