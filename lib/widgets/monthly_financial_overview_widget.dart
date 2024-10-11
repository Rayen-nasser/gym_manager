import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:gym_energy/model/member.dart';
import 'package:gym_energy/model/sport.dart';

class GymMonthlyFinancialOverview extends StatelessWidget {
  final List<Member> members;
  final DateTime currentDate;

  GymMonthlyFinancialOverview({
    required this.members,
    required this.currentDate,
  });

  @override
  Widget build(BuildContext context) {
    final currentRevenue = _calculateCurrentRevenue();
    final expectedRevenue = _calculateExpectedRevenue();
    final totalRevenue = currentRevenue + expectedRevenue;
    final sportBreakdown = _calculateSportBreakdown();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;
        return Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الملخص المالي الشهري للنادي',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: isTablet ? 24 : 16),
                if (isTablet)
                  _buildTabletLayout(currentRevenue, expectedRevenue, totalRevenue, sportBreakdown)
                else
                  _buildPhoneLayout(currentRevenue, expectedRevenue, totalRevenue, sportBreakdown),
                SizedBox(height: isTablet ? 24 : 16),
                _buildMonthProgressIndicator(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabletLayout(double currentRevenue, double expectedRevenue, double totalRevenue, Map<String, double> sportBreakdown) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: _buildRevenueChart(currentRevenue, expectedRevenue),
        ),
        SizedBox(width: 24),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRevenueInfo(currentRevenue, expectedRevenue, totalRevenue),
              SizedBox(height: 24),
              _buildSportBreakdown(sportBreakdown),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneLayout(double currentRevenue, double expectedRevenue, double totalRevenue, Map<String, double> sportBreakdown) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: _buildRevenueChart(currentRevenue, expectedRevenue),
        ),
        SizedBox(height: 16),
        _buildRevenueInfo(currentRevenue, expectedRevenue, totalRevenue),
        SizedBox(height: 16),
        _buildSportBreakdown(sportBreakdown),
      ],
    );
  }

  Widget _buildRevenueChart(double currentRevenue, double expectedRevenue) {
    // Check if both values are greater than zero
    if (currentRevenue <= 0 && expectedRevenue <= 0) {
      return Center(child: Text('لا توجد بيانات لعرضها')); // "No data to display"
    }

    return PieChart(
      PieChartData(
        sectionsSpace: 0,
        centerSpaceRadius: 40,
        sections: [
          if (currentRevenue > 0) // Only add section if the value is greater than zero
            PieChartSectionData(
              color: Colors.blue,
              value: currentRevenue,
              title: 'الحالي',
              radius: 100,
              titleStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Cairo',
              ),
            ),
          if (expectedRevenue > 0) // Only add section if the value is greater than zero
            PieChartSectionData(
              color: Colors.green,
              value: expectedRevenue,
              title: 'المتوقع',
              radius: 100,
              titleStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Cairo',
              ),
            ),
        ],
      ),
    );
  }


  Widget _buildRevenueInfo(double currentRevenue, double expectedRevenue, double totalRevenue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('الإيرادات الحالية', currentRevenue),
        _buildInfoRow('الإيرادات المتوقعة', expectedRevenue),
        Divider(),
        _buildInfoRow('إجمالي الإيرادات', totalRevenue, isTotal: true),
      ],
    );
  }

  Widget _buildSportBreakdown(Map<String, double> sportBreakdown) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تفصيل الإيرادات حسب الرياضة',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        ...sportBreakdown.entries.map((entry) => _buildInfoRow(entry.key, entry.value)).toList(),
      ],
    );
  }

  Widget _buildInfoRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            NumberFormat.currency(symbol: 'د.ت', decimalDigits: 2, locale: 'ar_TN').format(amount),
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.green[700] : Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthProgressIndicator(BuildContext context) {
    final daysInMonth = DateTime(currentDate.year, currentDate.month + 1, 0).day;
    final dayOfMonth = currentDate.day;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: dayOfMonth / daysInMonth,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
        ),
        SizedBox(height: 8),
        Text(
          'تقدم الشهر: ${dayOfMonth} من ${daysInMonth}',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  double _calculateCurrentRevenue() {
    return members.fold(0.0, (sum, member) => sum + member.totalPaid);
  }

  double _calculateExpectedRevenue() {
    final currentMonth = DateTime.now().month; // Get the current month
    return members.fold(0.0, (sum, member) {
      // Check if the member is active and their expiration month is the current month
      if (member.isActive && member.membershipExpiration.month == currentMonth) {
        return sum + member.totalSportPrices(); // Add the member's total sport prices to the sum
      }
      return sum; // Return the current sum if the conditions are not met
    });
  }


  Map<String, double> _calculateSportBreakdown() {
    Map<String, double> breakdown = {};
    for (var member in members) {
      if (member.isActive && member.isExpirationActive) {
        for (var sport in member.sports) {
          breakdown[sport.name] = (breakdown[sport.name] ?? 0) + sport.price;
        }
      }
    }
    return breakdown;
  }
}