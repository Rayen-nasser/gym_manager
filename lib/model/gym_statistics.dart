import 'package:cloud_firestore/cloud_firestore.dart';
import 'member.dart'; // Import your Member class
import 'sport.dart';  // Import your Sport class

class GymStatistics {
  final List<Member> members;

  GymStatistics({required this.members});

  // Calculate the total income for the gym (sum of all member payments)
  double totalIncome() {
    return members.fold(0.0, (sum, member) => sum + member.totalPaid);
  }

  // Calculate the total income for a specific month
  double totalIncomeForMonth(int month, int year) {
    double total = 0.0;
    for (var member in members) {
      for (var paymentDate in member.paymentDates) {
        if (paymentDate.month == month && paymentDate.year == year) {
          total += member.totalPaid;
        }
      }
    }
    return total;
  }

  // Count how many members renewed in a specific month
  int renewalsInMonth(int month, int year) {
    return members.where((member) {
      return member.paymentDates.any((date) =>
      date.month == month && date.year == year &&
          member.isExpirationActive); // Check if the member renewed
    }).length;
  }

  // Get the number of active members
  int numberOfActiveMembers() {
    return members.where((member) => member.isActive).length;
  }

  // Get the total income from a specific sport (sum of all sport enrollments)
  double totalIncomeFromSport(String sportId) {
    double total = 0.0;
    for (var member in members) {
      for (var sport in member.sports) {
        if (sport.id == sportId) {
          total += sport.price;
        }
      }
    }
    return total;
  }

  // Get the most popular sport based on the number of members enrolled
  Sport? mostPopularSport() {
    Map<String, int> sportCount = {};
    for (var member in members) {
      for (var sport in member.sports) {
        sportCount[sport.id] = (sportCount[sport.id] ?? 0) + 1;
      }
    }

    // Find the sport with the most enrollments
    String? mostPopularSportId;
    int maxCount = 0;
    sportCount.forEach((sportId, count) {
      if (count > maxCount) {
        mostPopularSportId = sportId;
        maxCount = count;
      }
    });

    // Return the most popular sport if it exists
    return members
        .expand((member) => member.sports)
        .firstWhere((sport) => sport.id == mostPopularSportId,);
  }

  // Calculate the average price of enrolled sports per member
  double averageSportPricePerMember() {
    double totalSportPrices = 0.0;
    int totalMembersWithSports = 0;

    for (var member in members) {
      if (member.sports.isNotEmpty) {
        totalSportPrices += member.totalSportPrices();
        totalMembersWithSports += 1;
      }
    }

    return totalMembersWithSports > 0 ? totalSportPrices / totalMembersWithSports : 0.0;
  }
}
