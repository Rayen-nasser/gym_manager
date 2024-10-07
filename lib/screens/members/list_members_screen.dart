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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MembersProvider>(context, listen: false);
      provider.fetchMembers();
      provider.updateFilters(
        filter: widget.selectedFilter,
        sport: widget.selectedSport,
        expiredOnly: widget.showExpiredOnly,
        activeMembers: widget.showActiveMembers,
      );
    });
  }

  @override
  void didUpdateWidget(MembersScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedFilter != widget.selectedFilter ||
        oldWidget.selectedSport != widget.selectedSport ||
        oldWidget.showExpiredOnly != widget.showExpiredOnly ||
        oldWidget.showActiveMembers != widget.showActiveMembers) {
      final provider = Provider.of<MembersProvider>(context, listen: false);
      provider.updateFilters(
        filter: widget.selectedFilter,
        sport: widget.selectedSport,
        expiredOnly: widget.showExpiredOnly,
        activeMembers: widget.showActiveMembers,
      );
    }
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
              return filteredMembers.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isTablet ? (isTabletVertical ? 2 : 4) : 1,
                  childAspectRatio: isTablet ? (isTabletVertical ? 1.6 : 1.3) : 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 6,
                ),
                itemCount: filteredMembers.length,
                itemBuilder: (context, index) {
                  final client = filteredMembers[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClientDetailScreen(client: client),
                        ),
                      );
                    },
                    child: isTablet
                        ? TabletClientCartWidget(client: client)
                        : PhoneCartClientWidget(client: client),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
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