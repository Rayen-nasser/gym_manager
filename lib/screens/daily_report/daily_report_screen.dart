import 'package:flutter/material.dart';
import 'package:gym_energy/widgets/sport_row.dart';
import 'package:provider/provider.dart';
import 'package:gym_energy/widgets/metrics_card_widget.dart';
import 'package:gym_energy/widgets/weekly_revenue_chart.dart';
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
      elevation: 2, // Add elevation for better appearance
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الرياضات الأكثر شعبية',
              style: TextStyle(
                fontSize: 18, // Increased font size for title
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo', // Use Cairo font
              ),
            ),
            const SizedBox(height: 10),
            ...sortedSports.map((entry) => SportRow(
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