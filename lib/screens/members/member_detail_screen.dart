import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gym_energy/screens/members/add_edit_member_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../model/member.dart';
import '../../model/sport.dart';
import '../../provider/members_provider.dart';

class MemberDetailScreen extends StatelessWidget {
  final String memberId;

  const MemberDetailScreen({
    Key? key,
    required this.memberId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Consumer<MembersProvider>(
      builder: (context, provider, child) {
        // Find the member in all members first, not just filtered
        Member? member;
        try {
          member = provider.filteredMembers.firstWhere(
            (m) => m.id == memberId,
            orElse: () => throw Exception('Member not found'),
          );
        } catch (e) {
          // Handle the case where member is not found
          return Scaffold(
            appBar: AppBar(
              title: Text('Member Details', style: GoogleFonts.cairo()),
              centerTitle: true,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Member not found',
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The requested member could not be found',
                    style: GoogleFonts.cairo(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Go Back', style: GoogleFonts.cairo()),
                  ),
                ],
              ),
            ),
          );
        }

        final isExpired = member.membershipExpiration.isBefore(DateTime.now());

        return Scaffold(
          appBar: AppBar(
            title: Text(member.fullName, style: GoogleFonts.cairo()),
            centerTitle: true,
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) =>
                    _handleMenuAction(context, value, member!),
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('تعديل العضو', style: GoogleFonts.cairo()),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'block',
                    child: ListTile(
                      leading: Icon(Icons.block),
                      title: Text(
                          member!.isActive ? 'حظر العضو' : 'إلغاء حظر العضو',
                          style: GoogleFonts.cairo()),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete),
                      title: Text('حذف العضو', style: GoogleFonts.cairo()),
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 20 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildClientHeader(context, isExpired, member),
                  const SizedBox(height: 24),
                  _buildContactInfo(context, member),
                  const SizedBox(height: 24),
                  _buildMembershipInfo(context, isExpired, member),
                  const SizedBox(height: 24),
                  _buildFinancialInfo(context, isTablet, member),
                  const SizedBox(height: 24),
                  _buildSportsInfo(context, member),
                  const SizedBox(height: 24),
                  _buildAdditionalInfo(context, member),
                  const SizedBox(height: 24),
                  _buildActionButtons(context, isExpired, member),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleMenuAction(BuildContext context, String value, Member member) {
    switch (value) {
      case 'edit':
        _editMember(context, member);
        break;
      case 'block':
        _blockMember(context, member);
        break;
      case 'delete':
        _deleteMember(context, member);
        break;
    }
  }

  Future<void> _editMember(BuildContext context, Member member) async {
    final updatedMember = await Navigator.of(context).push<Member>(
      MaterialPageRoute(
          builder: (context) => AddEditMemberScreen(member: member)),
    );

    if (updatedMember != null) {
      await Provider.of<MembersProvider>(context, listen: false).fetchMembers();
    }
  }

  void _blockMember(BuildContext context, Member member) async {
    try {
      await Provider.of<MembersProvider>(context, listen: false)
          .toggleBlockMember(member);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(member.isActive
              ? 'تم حظر العضو: ${member.fullName}'
              : 'تم إلغاء حظر العضو: ${member.fullName}'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء حظر/إلغاء حظر العضو: $e'),
        ),
      );
    }
  }

  void _deleteMember(BuildContext context, Member client) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('تأكيد الحذف', style: GoogleFonts.cairo()),
          content: Text('هل أنت متأكد من رغبتك في حذف هذا العضو؟',
              style: GoogleFonts.cairo()),
          actions: [
            TextButton(
              child: Text('إلغاء', style: GoogleFonts.cairo()),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('حذف', style: GoogleFonts.cairo()),
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await Provider.of<MembersProvider>(context, listen: false)
                      .deleteMember(client);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('تم حذف العضو: ${client.fullName}')),
                  );
                  Navigator.of(context).pop(); // Close the ClientDetailScreen
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'حدث خطأ أثناء حذف العضو: ${client.fullName}')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildClientHeader(
      BuildContext context, bool isMembershipExpired, Member member) {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            member.fullName.substring(0, 2).toUpperCase(),
            style: GoogleFonts.cairo(fontSize: 24, color: Colors.white),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                member.fullName,
                style: GoogleFonts.cairo(
                    fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              _buildMembershipStatus(isMembershipExpired),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMembershipStatus(bool isExpired) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isExpired ? Colors.red : Colors.green,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isExpired ? 'منتهية الصلاحية' : 'نشطة',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }

  Widget _buildContactInfo(BuildContext context, Member member) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('معلومات الاتصال',
                style: GoogleFonts.cairo(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildInfoRow(
                Icons.email, 'البريد الإلكتروني:', member.email, context),
            const SizedBox(height: 8),
            _buildInfoRow(
                Icons.phone, 'رقم الهاتف:', member.phoneNumber, context),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialInfo(
      BuildContext context, bool isTablet, Member member) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المعلومات المالية',
                style: GoogleFonts.cairo(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildTotalPaid(context, isTablet, member),
            const SizedBox(height: 8),
            Text(
              'تواريخ الدفع:',
              style:
                  GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: member.paymentDates
                  .map((date) => Text(
                        DateFormat('yyyy-MM-dd').format(date),
                        style: GoogleFonts.cairo(fontSize: 14),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalPaid(BuildContext context, bool isTablet, Member member) {
    // Add isTablet parameter
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'إجمالي المدفوع:',
            style: TextStyle(
              fontSize: isTablet ? 14 : 18, // Adjust font size for tablets
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
              color: Colors.blue,
            ),
          ),
          Text(
            '${member.totalSportPrices().toStringAsFixed(2)} دينار',
            style: TextStyle(
              fontSize: isTablet ? 14 : 18, // Adjust font size for tablets
              fontWeight: FontWeight.bold,
              color: Colors.blue,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSportsInfo(BuildContext context, Member member) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الرياضات المسجلة',
                style: GoogleFonts.cairo(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Column(
              children: member.sports
                  .map((sport) => _buildSportItem(sport, context))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSportItem(Sport sport, BuildContext context) {
    return ListTile(
      title: Text(sport.name, style: GoogleFonts.cairo(fontSize: 16)),
      subtitle: Text('السعر: ${sport.price.toStringAsFixed(2)} دينار',
          style: GoogleFonts.cairo(fontSize: 14)),
      leading: Icon(Icons.sports, color: Theme.of(context).primaryColor),
    );
  }

  Widget _buildAdditionalInfo(BuildContext context, Member member) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('معلومات إضافية',
                style: GoogleFonts.cairo(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.calendar_today, 'تاريخ الإنشاء:',
                DateFormat('yyyy-MM-dd').format(member.createdAt), context),
            if (member.assignedTrainerId != null) ...[
              const SizedBox(height: 8),
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('trainers')
                    .doc(member.assignedTrainerId)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text('خطأ في تحميل بيانات المدرب',
                        style: GoogleFonts.cairo(color: Colors.red));
                  }
                  if (snapshot.hasData && snapshot.data!.exists) {
                    final trainerData =
                        snapshot.data!.data() as Map<String, dynamic>;
                    final trainerName =
                        '${trainerData['firstName']} ${trainerData['lastName']}';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(Icons.person, 'المدرب المعين:',
                            trainerName, context),
                        const SizedBox(height: 4),
                        _buildInfoRow(Icons.email, 'بريد المدرب:',
                            trainerData['email'], context),
                        const SizedBox(height: 4),
                        _buildInfoRow(Icons.phone, 'هاتف المدرب:',
                            trainerData['phoneNumber'], context),
                      ],
                    );
                  } else {
                    return Text('لم يتم العثور على بيانات المدرب',
                        style: GoogleFonts.cairo(color: Colors.orange));
                  }
                },
              ),
            ],
            if (member.clientIds != null && member.clientIds!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow(Icons.group, 'عدد العملاء:',
                  member.clientIds!.length.toString(), context),
              const SizedBox(height: 8),
              Text('الرياضات التي يدربها:',
                  style: GoogleFonts.cairo(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: member.sports
                    .map((sport) => Padding(
                          padding: const EdgeInsets.only(left: 16, top: 4),
                          child: Text(
                            '• ${sport.name}',
                            style: GoogleFonts.cairo(fontSize: 14),
                          ),
                        ))
                    .toList(),
              ),
            ],
            if (member.notes != null && member.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow(Icons.note, 'ملاحظات:', member.notes!, context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMembershipInfo(
      BuildContext context, bool isExpired, Member member) {
    final expirationDate =
        DateFormat('yyyy-MM-dd').format(member.membershipExpiration);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isExpired ? Colors.red[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isExpired ? Colors.red : Colors.green),
      ),
      child: Row(
        children: [
          Icon(
            isExpired ? Icons.warning : Icons.check_circle,
            color: isExpired ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'تاريخ انتهاء العضوية: $expirationDate',
              style: TextStyle(
                fontSize: 14,
                color: isExpired ? Colors.red[700] : Colors.green[700],
                fontWeight: FontWeight.w500,
                fontFamily: 'Cairo',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, bool isExpired, Member member) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            context: context,
            icon: Icons.email,
            label: 'البريد',
            onPressed: () => _launchEmail(context, member.email),
            color: Colors.blue,
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            context: context,
            icon: Icons.call,
            label: 'اتصال',
            onPressed: () => _launchCall(context, member.phoneNumber),
            color: Colors.green,
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            context: context,
            icon: Icons.refresh,
            label: 'تجديد',
            onPressed: isExpired
                ? () => _renewMembership(context, member)
                : null, // Disable the button if membership is active
            color: isExpired
                ? Colors.orange
                : Colors.grey, // Change color if disabled
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white, size: 18),
      label: Text(
        label,
        style: const TextStyle(
            color: Colors.white, fontFamily: 'Cairo', fontSize: 12),
      ),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildInfoRow(
      IconData icon, String label, String value, BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Flexible(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.cairo(
                color: Colors.black, // Default text color
              ),
              children: [
                TextSpan(
                  text: '$label ',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.grey[600], // Color for the label
                  ),
                ),
                TextSpan(
                  text: value,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    color: Theme.of(context)
                        .colorScheme
                        .onBackground, // Using onBackground from theme
                  ),
                ),
              ],
            ),
            overflow:
                TextOverflow.ellipsis, // Ensures the text doesn't overflow
          ),
        ),
      ],
    );
  }

  void _showMembershipActiveMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('العضوية لا تزال فعالة!')),
    );
  }

  void _launchEmail(BuildContext context, String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Your Subject Here',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        throw 'Could not launch $emailUri';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e')),
      );
    }
  }

  void _launchCall(BuildContext context, String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        throw 'Could not launch $phoneUri';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e')),
      );
    }
  }

  void _renewMembership(BuildContext context, Member member) async {
    DateTime newExpirationDate = DateTime.now().add(Duration(days: 30));
    double renewalFee = member.totalSportPrices();

    try {
      // Update Firestore
      await FirebaseFirestore.instance
          .collection('clients')
          .doc(member.id)
          .update({
        'membershipExpiration': Timestamp.fromDate(newExpirationDate),
        'paymentDates':
            FieldValue.arrayUnion([Timestamp.fromDate(DateTime.now())]),
        'totalPaid': FieldValue.increment(renewalFee),
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'تم تجديد العضوية حتى ${newExpirationDate.toLocal().toString().split(' ')[0]}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل تجديد العضوية: $e')),
      );
    }
  }
}
