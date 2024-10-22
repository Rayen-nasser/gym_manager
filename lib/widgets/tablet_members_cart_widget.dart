import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../model/member.dart';
import '../screens/members/member_detail_screen.dart';

class TabletClientCartWidget extends StatelessWidget {
  final Member member;
  final int index; // Add index parameter

  const TabletClientCartWidget({
    Key? key,
    required this.member,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isMembershipExpired =
    member.membershipExpiration.isBefore(DateTime.now());

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 4,),
      child: InkWell(
        onTap: () {
          // Navigate to the client detail screen on tap
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MemberDetailScreen(memberId: member.id)),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.1),
                Theme.of(context).primaryColor.withOpacity(0.05),
              ],
            ),
          ),
          child: SingleChildScrollView(  // Wrap with SingleChildScrollView
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildNameRow(context),
                  const SizedBox(height: 10),
                  buildTotalPaid(context),
                  const SizedBox(height: 10),
                  buildMembershipInfo(context, isMembershipExpired),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildNameRow(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            '$index',
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            '${member.firstName} ${member.lastName}',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget buildTotalPaid(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'إجمالي المدفوع:',
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          Text(
            '${member.totalSportPrices().toStringAsFixed(2)} دينار',
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMembershipInfo(BuildContext context, bool isExpired) {
    final expirationDate =
    DateFormat('yyyy-MM-dd').format(member.membershipExpiration);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isExpired
            ? Colors.red.withOpacity(0.1)
            : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            isExpired
                ? Icons.warning_amber_rounded
                : Icons.check_circle_outline,
            color: isExpired ? Colors.red : Colors.green,
            size: 18,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isExpired ? 'العضوية منتهية' : 'العضوية نشطة',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isExpired ? Colors.red : Colors.green,
                  ),
                ),
                Text(
                  'تاريخ الانتهاء: $expirationDate',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
