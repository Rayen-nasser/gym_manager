import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../model/member.dart';

class WeeklyRevenueChart extends StatelessWidget {
  final List<Member> members;

  WeeklyRevenueChart(this.members);

  @override
  Widget build(BuildContext context) {
    return _buildWeeklyRevenueChart();
  }

  Widget _buildWeeklyRevenueChart() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    final List<DailyRevenue> weeklyData = [];
    final arabicDays = [
      'الأحد',
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت'
    ];

    for (int i = 0; i < 7; i++) {
      final currentDate = startOfWeek.add(Duration(days: i));
      final dayRevenue = _calculateDailyRevenue(currentDate);
      weeklyData.add(DailyRevenue(
        date: currentDate,
        revenue: dayRevenue,
        arabicDayName: arabicDays[i],
      ));
    }

    // Find maximum revenue and ensure it's not zero
    final maxRevenue = weeklyData.map((d) => d.revenue).reduce(max);
    final roundedMax = max((maxRevenue / 1000).ceil() * 1000.0, 1000.0); // Ensure minimum of 1000
    final horizontalInterval = max(roundedMax / 5, 200.0); // Ensure minimum interval of 200

    return LayoutBuilder(
      builder: (context, constraints) {
        final chartHeight = constraints.maxWidth * 0.7;

        return Container(
          height: chartHeight + 80,
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'إيرادات الأسبوع',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: roundedMax,
                        barGroups: _createBarGroups(weeklyData, constraints.maxWidth),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: horizontalInterval, // Using safe interval
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.grey[300],
                            strokeWidth: 1,
                            dashArray: [5, 5],
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < weeklyData.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      weeklyData[index].arabicDayName,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox();
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 46,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toStringAsFixed(0)} د ',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                    fontFamily: 'Cairo',
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            tooltipBorder: BorderSide(
                              color: Colors.blueGrey.shade800,
                              width: 1,
                            ),
                            tooltipPadding: const EdgeInsets.all(8),
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final revenue = weeklyData[groupIndex].revenue;
                              final date = weeklyData[groupIndex].date;
                              return BarTooltipItem(
                                '${DateFormat.yMMMd('ar').format(date)}\n'
                                    '${NumberFormat.currency(
                                  symbol: 'ت.د',
                                  decimalDigits: 0,
                                  locale: 'ar_TN',
                                ).format(revenue)}',
                                TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Cairo',
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  List<BarChartGroupData> _createBarGroups(List<DailyRevenue> data, double maxWidth) {
    // Calculate optimal bar width based on screen width
    final barWidth = (maxWidth - 64) / data.length * 0.6; // 60% of available space

    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final dayData = entry.value;

      // Define gradient colors based on revenue
      final gradientColors = [
        Colors.blue[300]!,
        Colors.blue[600]!,
      ];

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: dayData.revenue,
            width: barWidth,
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: data.map((d) => d.revenue).reduce(max),
              color: Colors.grey[200],
            ),
          ),
        ],
      );
    }).toList();
  }

  double _calculateDailyRevenue(DateTime date) {
    return members.fold(0.0, (sum, member) {
      final dayPayments = member.paymentDates.where((paymentDate) =>
      paymentDate.year == date.year &&
          paymentDate.month == date.month &&
          paymentDate.day == date.day,
      );

      return sum + (dayPayments.length * member.totalPaid);
    });
  }
}

class DailyRevenue {
  final DateTime date;
  final double revenue;
  final String arabicDayName;

  DailyRevenue({
    required this.date,
    required this.revenue,
    required this.arabicDayName,
  });
}