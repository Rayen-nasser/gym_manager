import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gym_energy/model/member.dart';

class MetricsCardsWidget extends StatelessWidget {
  final List<Member> members;
  final int monthsToShow;

  const MetricsCardsWidget({
    Key? key,
    required this.members,
    this.monthsToShow = 6,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      symbol: 'دينار ',
      decimalDigits: 0,
    );

    final now = DateTime.now();

    // Handling month transition for revenue calculation
    final revenueHistory = List.generate(monthsToShow, (index) {
      final month = DateTime(now.year, now.month - index, 1);
      return Member.calculateTotalRevenueForMonth(members, month);
    }).reversed.toList();

    // Ensuring safe revenue calculation when no revenue data is available
    final totalRevenue = revenueHistory.isNotEmpty ? revenueHistory.reduce((a, b) => a + b) : 0.0;

    final activeMembers = members.where((m) => m.isActive).length;
    final averageRevenuePerMember = activeMembers > 0
        ? totalRevenue / activeMembers.toDouble()
        : 0.0;


    // Fixed calculation for members joined in the last 30 days
    final joinedMembers = members.where((m) => m.createdAt.isAfter(now.subtract(Duration(days: 30)))).length;

    // Non-renewed and renewed members calculations
    final nonRenewedMembers = members.where((m) => m.isActive && m.membershipExpiration.isBefore(now)).length;
    final renewedMembers = members.where((m) => m.isActive && m.membershipExpiration.isAfter(now)).length;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('المؤشرات الرئيسية'),
          const SizedBox(height: 10),
          _buildMainMetrics(formatter, totalRevenue, activeMembers),
          const SizedBox(height: 20),
          _buildSectionTitle('تحليل العضوية'),
          const SizedBox(height: 10),
          _buildMembershipAnalysis(formatter, joinedMembers, nonRenewedMembers, renewedMembers, averageRevenuePerMember),
          const SizedBox(height: 20),
          _buildRevenueChart(revenueHistory),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Cairo',
      ),
    );
  }

  Widget _buildMainMetrics(NumberFormat formatter, double totalRevenue, int activeMembers) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            title: 'إجمالي الإيرادات',
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
            title: 'الأعضاء النشطون',
            value: activeMembers.toString(),
            icon: Icons.people,
            color: const Color(0xFF1E88E5),
            gradient: const LinearGradient(
              colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMembershipAnalysis(NumberFormat formatter, int joinedMembers, int nonRenewedMembers, int renewedMembers, double averageRevenuePerMember) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'الأعضاء الجدد',
                value: joinedMembers.toString(),
                icon: Icons.group_add,
                color: const Color(0xFFFB8C00),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFB8C00), Color(0xFFFFA726)],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                title: 'أعضاء لم يجددوا',
                value: nonRenewedMembers.toString(),
                icon: Icons.cancel,
                color: const Color(0xFFEF5350),
                gradient: const LinearGradient(
                  colors: [Color(0xFFEF5350), Color(0xFFE57373)],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _MetricCard(
          title: 'الأعضاء الذين جددوا',
          value: renewedMembers.toString(),
          icon: Icons.check_circle,
          color: const Color(0xFF4CAF50),
          gradient: const LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueChart(List<double> revenueHistory) {
    return Container(
      height: 250, // Increased height for the card
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title inside the card
          Text(
            'تحليل الإيرادات',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10), // Space between title and chart
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        final now = DateTime.now();
                        final adjustedMonth = now.subtract(Duration(days: (revenueHistory.length - 1 - value.toInt()) * 30));
                        return Text(
                          DateFormat('MMM').format(adjustedMonth),
                          style: const TextStyle(
                            color: Color(0xff68737d),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      },
                      interval: 1, // Ensure x-axis ticks are properly spaced
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: revenueHistory.length.toDouble() - 1,
                minY: 0,
                maxY: revenueHistory.isNotEmpty
                    ? revenueHistory.reduce((a, b) => a > b ? a : b) * 1.2
                    : 1.0,
                lineBarsData: [
                  LineChartBarData(
                    spots: revenueHistory.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value);
                    }).toList(),
                    isCurved: true,
                    color: const Color(0xFF43A047),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF43A047).withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Gradient gradient;

  const _MetricCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.gradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontFamily: 'Cairo',
                    ),
                    overflow: TextOverflow.ellipsis,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
