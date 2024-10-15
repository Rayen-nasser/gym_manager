import 'package:flutter/material.dart';
import 'package:gym_energy/widgets/sport_row.dart';
import 'package:provider/provider.dart';
import 'package:gym_energy/widgets/metrics_card_widget.dart';
import 'package:gym_energy/widgets/weekly_revenue_chart.dart';
import '../../model/user.dart';
import '../../provider/gym_provider.dart';
import '../../widgets/monthly_financial_overview_widget.dart';
import '../../services/auth_service.dart'; // Import the AuthService

class GymAnalyticsDashboard extends StatelessWidget {
  const GymAnalyticsDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: AuthService().getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final user = snapshot.data;
        if (user == null || !user.isAdmin()) {
          return Scaffold(
            body: Center(
              child: Text(
                'You do not have permission to access this page.',
                style: TextStyle(fontSize: 18, fontFamily: 'Cairo'),
              ),
            ),
          );
        }

        return ChangeNotifierProvider(
          create: (context) => GymProvider()..loadData(),
          child: Scaffold(
            body: Consumer<GymProvider>(
              builder: (context, gymProvider, child) {
                if (gymProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await gymProvider.loadData();
                  },
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
      },
    );
  }

  Widget _buildSportsDistribution(GymProvider gymProvider) {
    final sortedSports = gymProvider.sportsDistribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الرياضات الأكثر شعبية',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
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
