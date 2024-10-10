import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';  // Import Provider
import 'package:gym_energy/widgets/metrics_card_widget.dart';
import 'package:gym_energy/widgets/weekly_revenue_chart.dart';
import 'package:gym_energy/model/member.dart';
import '../../provider/gym_provider.dart';
import '../../widgets/monthly_financial_overview_widget.dart';

class GymAnalyticsDashboard extends StatelessWidget {
  const GymAnalyticsDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GymProvider()..loadData(), // Initialize the provider
      child: Scaffold(
        body: Consumer<GymProvider>(
          builder: (context, gymProvider, child) {
            if (gymProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: gymProvider.loadData,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  MetricsCardsWidget(members: gymProvider.members),
                  const SizedBox(height: 20),
                  WeeklyRevenueChart(gymProvider.members),
                  const SizedBox(height: 20),
                  GymMonthlyFinancialOverview(
                    members: gymProvider.members,
                    currentDate: DateTime.now(),
                  ),
                  const SizedBox(height: 20),
                  _buildSportsDistribution(gymProvider),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSportsDistribution(GymProvider gymProvider) {
    final sortedSports = gymProvider.sportsDistribution.entries.toList()
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
              totalMembers: gymProvider.members.length,
            )),
          ],
        ),
      ),
    );
  }
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
