import 'package:flutter/material.dart';
import 'package:gym_energy/screens/members/member_detail_screen.dart';
import 'package:provider/provider.dart';
import '../../model/gym.dart';
import '../../model/member.dart';
import '../../model/sport.dart';
import '../../provider/gym_provider.dart';
import '../sport/add_edit_sport_screen.dart';

class GymScreen extends StatefulWidget {
  const GymScreen({Key? key}) : super(key: key);

  @override
  _GymScreenState createState() => _GymScreenState();
}

class _GymScreenState extends State<GymScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final gymProvider = GymProvider();
        gymProvider.loadGymData();
        return gymProvider;
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: Consumer<GymProvider>(
            builder: (context, gymProvider, child) {
              if (gymProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              return RefreshIndicator(
                onRefresh: () => gymProvider.loadGymData(),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return constraints.maxWidth > 600
                        ? _buildTabletLayout(gymProvider, constraints)
                        : _buildPhoneLayout(gymProvider);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTabletLayout(
      GymProvider gymProvider, BoxConstraints constraints) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildGymInfoSection(),
                ],
              ),
            ),
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildTrainersBySport(gymProvider),
                    const SizedBox(height: 16),
                    _buildSportsSection(context, gymProvider),
                  ],
                )),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneLayout(GymProvider gymProvider) {
    return ListView(
      children: [
        _buildGymInfoSection(),
        _buildTrainersBySport(gymProvider),
        _buildSportsSection(context, gymProvider),
      ],
    );
  }

  Widget _buildGymInfoSection() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'معلومات الجيم',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
            const SizedBox(height: 20),
            _buildInfoRow(
                Icons.fitness_center, 'اسم الجيم', staticGymInfo.name),
            _buildInfoRow(Icons.location_on, 'العنوان', staticGymInfo.address),
            _buildInfoRow(
                Icons.access_time, 'وقت الفتح', staticGymInfo.openingTime),
            _buildInfoRow(Icons.access_time_filled, 'وقت الإغلاق',
                staticGymInfo.closingTime),
            _buildInfoRow(
                Icons.phone, 'رقم الاتصال', staticGymInfo.contactNumber),
            _buildInfoRow(
                Icons.email, 'البريد الإلكتروني', staticGymInfo.email),
            _buildInfoRow(Icons.card_membership, 'معلومات العضوية',
                staticGymInfo.membershipInfo),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14, fontFamily: 'Cairo'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainersBySport(GymProvider gymProvider) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'المدربون',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
            const SizedBox(height: 16),
            _buildTrainersList(gymProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainersList(GymProvider gymProvider) {
    Map<String, List<Member>> trainersBySport = {};
    for (var trainer in gymProvider.gym.trainers) {
      for (var sport in gymProvider.gym.sports) {
        if (trainer.sports[0].id == sport.id) {
          trainersBySport.putIfAbsent(sport.name, () => []).add(trainer);
        }
      }
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: trainersBySport.length,
      itemBuilder: (context, index) {
        String sportName = trainersBySport.keys.elementAt(index);
        List<Member> trainers = trainersBySport[sportName]!;
        return _buildSportTrainersSection(sportName, trainers);
      },
    );
  }

  Widget _buildSportTrainersSection(String sportName, List<Member> trainers) {
    return ExpansionTile(
      title: Text(
        sportName,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
          color: Theme.of(context).primaryColor,
        ),
      ),
      children: trainers.map((trainer) => _buildTrainerTile(trainer)).toList(),
    );
  }

  Widget _buildTrainerTile(Member trainer) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
        child: Text(
          trainer.fullName.substring(0, 1).toUpperCase(),
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        trainer.fullName,
        style:
            const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
      ),
      subtitle: Text(
        trainer.email!,
        style: const TextStyle(fontFamily: 'Cairo'),
      ),
      trailing: Icon(Icons.arrow_forward_ios,
          color: Theme.of(context).primaryColor, size: 16),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    MemberDetailScreen(memberId: trainer.id)));
      },
    );
  }

  Widget _buildSportsSection(BuildContext context, GymProvider gymProvider) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الرياضات',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة رياضة',
                      style: TextStyle(fontFamily: 'Cairo')),
                  onPressed: () => _addSport(context, gymProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            gymProvider.gym.sports.isNotEmpty
                ? LayoutBuilder(
                    builder: (context, constraints) {
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: constraints.maxWidth > 600 ? 3 : 2,
                          childAspectRatio: 1.2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: gymProvider.gym.sports.length,
                        itemBuilder: (context, index) => _buildSportTile(
                            gymProvider.gym.sports[index], gymProvider),
                      );
                    },
                  )
                : const Center(
                    child: Text(
                      'لا توجد رياضات متاحة.',
                      style: TextStyle(
                          fontStyle: FontStyle.italic, fontFamily: 'Cairo'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildSportTile(Sport sport, GymProvider gymProvider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _editSport(sport, gymProvider),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Icon(Icons.sports,
                    size: 32, color: Theme.of(context).primaryColor),
              ),
              const SizedBox(height: 4),
              Text(
                sport.name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '\$${sport.price.toStringAsFixed(2)}',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addSport(BuildContext context, GymProvider gymProvider) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditSportScreen(),
      ),
    );
    if (result != null) {
      gymProvider.loadGymData();
    }
  }

  Future<void> _editSport(Sport sport, GymProvider gymProvider) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditSportScreen(sport: sport),
      ),
    );
    if (result != null) {
      gymProvider.loadGymData();
    }
  }
}
