import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gym_energy/widgets/weekly_revenue_chart.dart';
import 'package:intl/intl.dart';
import 'package:gym_energy/model/member.dart';
import 'package:intl/intl.dart' as intl;

import '../../widgets/monthly_financial_overview_widget.dart';

class GymAnalyticsDashboard extends StatefulWidget {
  const GymAnalyticsDashboard({Key? key}) : super(key: key);

  @override
  State<GymAnalyticsDashboard> createState() => _GymAnalyticsDashboardState();
}

class _GymAnalyticsDashboardState extends State<GymAnalyticsDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Member> _members = [];
  bool _isLoading = true;
  String _selectedPeriod = 'month';

  // Arabic text constants
  static const String appTitle = 'تحليلات النادي الرياضي';
  static const String keyMetrics = 'المؤشرات الرئيسية';
  static const String totalRevenue_label = 'إجمالي الإيرادات';
  static const String activeMembers_label = 'الأعضاء النشطون';
  static const String avgRevenue = 'متوسط الإيراد/العضو';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final QuerySnapshot membersSnapshot =
      await _firestore.collection('clients').get();

      _members = membersSnapshot.docs
          .map((doc) => Member.fromMap(
          doc.data() as Map<String, dynamic>, doc.id))
          .toList();

    } catch (e) {
      print('Error loading data: $e');
    }
    setState(() => _isLoading = false);
  }

  // Financial calculations
  double get totalRevenue =>
      _members.fold(0, (sum, member) => sum + member.totalPaid);

  int get activeMembers =>
      _members.where((m) => m.isActive && m.isExpirationActive).length;

  double get averageRevenuePerMember =>
      activeMembers > 0 ? totalRevenue / activeMembers : 0;

  // Sports statistics
  Map<String, int> get sportsDistribution {
    final Map<String, int> distribution = {};
    for (var member in _members) {
      for (var sport in member.sports) {
        distribution[sport.name] = (distribution[sport.name] ?? 0) + 1;
      }
    }
    return distribution;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(
            appTitle,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color(0xFF1E88E5),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadData,
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF1E88E5).withOpacity(0.1),
                Colors.white,
              ],
            ),
          ),
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildMetricsCards(),
                const SizedBox(height: 20),
                WeeklyRevenueChart(_members),
                const SizedBox(height: 20),
                GymMonthlyFinancialOverview(
                  members: _members, // Pass your list of Member objects
                  currentDate: DateTime.now(), // Or pass a specific date
                ),
                const SizedBox(height: 20),
                _buildSportsDistribution(),
              ],
            ),
          ),
        ),
    );
  }

  Widget _buildMetricsCards() {
    final formatter = intl.NumberFormat.currency(
      symbol: 'دينار ',
      decimalDigits: 0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          keyMetrics,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: totalRevenue_label,
                value: formatter.format(totalRevenue),
                icon: Icons.attach_money,
                color: const Color(0xFF43A047),
                gradient: const LinearGradient(
                  colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                title: activeMembers_label,
                value: activeMembers.toString(),
                icon: Icons.people,
                color: const Color(0xFF1E88E5),
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _MetricCard(
          title: avgRevenue,
          value: formatter.format(averageRevenuePerMember),
          icon: Icons.trending_up,
          color: const Color(0xFF8E24AA),
          gradient: const LinearGradient(
            colors: [Color(0xFF8E24AA), Color(0xFFAB47BC)],
          ),
        ),
      ],
    );
  }

  Widget _buildSportsDistribution() {
    final sortedSports = sportsDistribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Popular Sports',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ...sortedSports.map((entry) => _SportRow(
              sportName: entry.key,
              memberCount: entry.value,
              totalMembers: _members.length,
            )),
          ],
        ),
      ),
    );
  }
}

Widget _MetricCard({
  required String title,
  required String value,
  required IconData icon,
  required Color color,
  required Gradient gradient,
}) {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    ),
  );
}

class _SportRow extends StatelessWidget {
  final String sportName;
  final int memberCount;
  final int totalMembers;

  const _SportRow({
    required this.sportName,
    required this.memberCount,
    required this.totalMembers,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (memberCount / totalMembers * 100).toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(sportName),
              Text('$memberCount ($percentage%)'),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: memberCount / totalMembers,
            backgroundColor: Colors.grey[200],
          ),
        ],
      ),
    );
  }
}