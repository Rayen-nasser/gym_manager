import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'dart:math'; // For max function
import 'package:intl/intl.dart' as intl;

import '../model/member.dart';

class WeeklyRevenueChart extends StatelessWidget {
  final List<Member> members; // List of members to calculate revenue

  WeeklyRevenueChart(this.members); // Constructor to accept members

  Widget _buildWeeklyRevenueChart() {
    // Get current week's start and end dates
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    // Create daily revenue data structure
    final List<DailyRevenue> weeklyData = [];
    final arabicDays = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد'
    ];

    // Initialize data for each day of the week
    for (int i = 0; i < 7; i++) {
      final currentDate = startOfWeek.add(Duration(days: i));
      final dayRevenue = _calculateDailyRevenue(currentDate);
      weeklyData.add(DailyRevenue(
        date: currentDate,
        revenue: dayRevenue,
        arabicDayName: arabicDays[i],
      ));
    }

    // Find maximum revenue for scaling
    final maxRevenue = weeklyData.map((d) => d.revenue).reduce(max);
    final roundedMax = (maxRevenue / 1000).ceil() * 1000.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive height calculation
        final chartHeight = constraints.maxWidth * 0.7;

        return Container(
          height: chartHeight + 80, // Additional height for title and legend
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
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
                          horizontalInterval: roundedMax / 5,
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
                                  '${value.toStringAsFixed(0)} د ', // Clear labeling with currency symbol
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
                                '${intl.DateFormat.yMMMd('ar').format(date)}\n'
                                    '${intl.NumberFormat.currency(
                                  symbol: 'ت.د', // Currency symbol
                                  decimalDigits: 0,
                                  locale: 'ar_TN', // Use Tunisian Arabic locale
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

      // Calculate gradient colors based on revenue
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
          paymentDate.day == date.day);

      return sum + (dayPayments.length * member.totalPaid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildWeeklyRevenueChart();
  }
}

// Data model for daily revenue
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
