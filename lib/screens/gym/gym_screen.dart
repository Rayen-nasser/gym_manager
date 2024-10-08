import 'package:flutter/material.dart';
import '../../model/gym.dart';
import '../../model/member.dart';
import '../../model/sport.dart';
import '../../services/firestore_service.dart';

class GymScreen extends StatefulWidget {
  const GymScreen({Key? key}) : super(key: key);

  @override
  _GymScreenState createState() => _GymScreenState();
}

class _GymScreenState extends State<GymScreen> {
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadGymData();
  }

  Future<void> _loadGymData() async {
    await loadGymData();
    if (mounted) {  // Ensure the widget is still mounted before calling setState
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : RefreshIndicator(
          onRefresh: _loadGymData,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildGymInfoSection()),
              SliverToBoxAdapter(child: _buildTrainersSection()),
              SliverToBoxAdapter(child: _buildSportsSection()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGymInfoSection() {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
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
            SizedBox(height: 20),
            _buildInfoRow(Icons.fitness_center, 'اسم الجيم', staticGymInfo.name),
            _buildInfoRow(Icons.location_on, 'العنوان', staticGymInfo.address),
            _buildInfoRow(Icons.access_time, 'وقت الفتح', staticGymInfo.openingTime),
            _buildInfoRow(Icons.access_time_filled, 'وقت الإغلاق', staticGymInfo.closingTime),
            _buildInfoRow(Icons.phone, 'رقم الاتصال', staticGymInfo.contactNumber),
            _buildInfoRow(Icons.email, 'البريد الإلكتروني', staticGymInfo.email),
            _buildInfoRow(Icons.card_membership, 'معلومات العضوية', staticGymInfo.membershipInfo),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'Cairo',
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(fontSize: 14, fontFamily: 'Cairo'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainersSection() {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
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
            SizedBox(height: 20),
            _buildTrainersBySport(),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainersBySport() {
    Map<String, List<Member>> trainersBySport = {};
    for (var trainer in staticGymInfo.trainers) {
      for (var sport in staticGymInfo.sports) {
        if (trainer.sports[0].id == sport.id) {
          trainersBySport.putIfAbsent(sport.name, () => []).add(trainer);
        }
      }
    }

    return Column(
      children: trainersBySport.entries.map((entry) {
        return _buildSportSection(entry.key, entry.value);
      }).toList(),
    );
  }

  Widget _buildSportSection(String sportName, List<Member> trainers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sportName,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
            color: Theme.of(context).primaryColor,
          ),
        ),
        SizedBox(height: 12),
        trainers.isNotEmpty
            ? ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: trainers.length,
          itemBuilder: (context, index) => _buildTrainerTile(trainers[index]),
        )
            : Text(
          'لا يوجد مدربون متاحون.',
          style: TextStyle(fontStyle: FontStyle.italic, fontFamily: 'Cairo'),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTrainerTile(Member trainer) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(Icons.person, color: Theme.of(context).primaryColor),
        ),
        title: Text(
          trainer.fullName,
          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
        ),
        subtitle: Text(
          'البريد الإلكتروني: ${trainer.email}',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        // trailing: ElevatedButton.icon(
        //   icon: Icon(Icons.bookmark),
        //   label: Text('حجز', style: TextStyle(fontFamily: 'Cairo')),
        //   onPressed: () {
        //     // Implement booking functionality
        //   },
        //   style: ElevatedButton.styleFrom(
        //     backgroundColor: Theme.of(context).primaryColor,
        //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        //   ),
        // ),
      ),
    );
  }

  Widget _buildSportsSection() {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الرياضات',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 20),
            staticGymInfo.sports.isNotEmpty
                ? ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: staticGymInfo.sports.length,
              itemBuilder: (context, index) => _buildSportTile(staticGymInfo.sports[index]),
            )
                : Text(
              'لا توجد رياضات متاحة.',
              style: TextStyle(fontStyle: FontStyle.italic, fontFamily: 'Cairo'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSportTile(Sport sport) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(Icons.sports, color: Theme.of(context).primaryColor),
        ),
        title: Text(
          sport.name,
          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
        ),
        subtitle: Text(
          'السعر: \$${sport.price.toStringAsFixed(2)}',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        trailing: ElevatedButton(
          onPressed: () => _registerForSport(sport),
          child: Text('سجل', style: TextStyle(fontFamily: 'Cairo')),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
      ),
    );
  }

  void _registerForSport(Sport sport) {
    // TODO: Implement registration logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم التسجيل في رياضة ${sport.name} بنجاح!', style: TextStyle(fontFamily: 'Cairo')),
        duration: Duration(seconds: 2),
      ),
    );
  }
}