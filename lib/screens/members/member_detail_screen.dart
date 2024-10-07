import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gym_energy/screens/members/add_edit_member_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../model/member.dart';
import '../../model/sport.dart';

class ClientDetailScreen extends StatelessWidget {
  final Member client;

  const ClientDetailScreen({
    Key? key,
    required this.client,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    bool isMembershipExpired = client.membershipExpiration.isBefore(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text(client.fullName, style: GoogleFonts.cairo()),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, value),
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
                  title: Text('حظر العضو', style: GoogleFonts.cairo()),
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
              _buildClientHeader(context, isMembershipExpired),
              const SizedBox(height: 24),
              _buildContactInfo(context),
              const SizedBox(height: 24),
              _buildMembershipInfo(context, isMembershipExpired),
              const SizedBox(height: 24),
              _buildFinancialInfo(context, isTablet),
              const SizedBox(height: 24),
              _buildSportsInfo(context),
              const SizedBox(height: 24),
              _buildAdditionalInfo(context),
              const SizedBox(height: 24),
              _buildActionButtons(context, isMembershipExpired),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String value) {
    switch (value) {
      case 'edit':
        _editMember(context);
        break;
      case 'block':
        _blockMember(context);
        break;
      case 'delete':
        _deleteMember(context, client);
        break;
    }
  }

  void _editMember(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddEditClientScreen()));
  }

  void _blockMember(BuildContext context) {
    // TODO: Implement block member functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('حظر العضو: ${client.fullName}')),
    );
  }

  void _deleteMember(BuildContext context, Member client) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('تأكيد الحذف', style: GoogleFonts.cairo()),
          content: Text('هل أنت متأكد من رغبتك في حذف هذا العضو؟', style: GoogleFonts.cairo()),
          actions: [
            TextButton(
              child: Text('إلغاء', style: GoogleFonts.cairo()),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('حذف', style: GoogleFonts.cairo()),
              onPressed: () async {
                // Close the dialog before performing the delete action
                Navigator.of(context).pop();

                try {
                  // Deleting member from Firebase Firestore (assuming 'members' collection and client.id exists)
                  await FirebaseFirestore.instance
                      .collection('members')
                      .doc(client.id)
                      .delete();

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('تم حذف العضو: ${client.fullName}')),
                  );
                } catch (error) {
                  // Show error message in case of failure
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('حدث خطأ أثناء حذف العضو: ${client.fullName}')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildClientHeader(BuildContext context, bool isMembershipExpired) {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            client.fullName.substring(0, 2).toUpperCase(),
            style: GoogleFonts.cairo(fontSize: 24, color: Colors.white),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                client.fullName,
                style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.bold),
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

  Widget _buildContactInfo(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('معلومات الاتصال', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.email, 'البريد الإلكتروني:', client.email, context),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.phone, 'رقم الهاتف:', client.phoneNumber, context),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialInfo(BuildContext context, bool isTablet) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المعلومات المالية', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildTotalPaid(context, isTablet),
            const SizedBox(height: 8),
            Text(
              'تواريخ الدفع:',
              style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: client.paymentDates.map((date) => Text(
                DateFormat('yyyy-MM-dd').format(date),
                style: GoogleFonts.cairo(fontSize: 14),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalPaid(BuildContext context, bool isTablet) { // Add isTablet parameter
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
            '${client.totalSportPrices().toStringAsFixed(2)} دينار',
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

  Widget _buildSportsInfo(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الرياضات المسجلة', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Column(
              children: client.sports.map((sport) => _buildSportItem(sport, context)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSportItem(Sport sport, BuildContext context) {
    return ListTile(
      title: Text(sport.name, style: GoogleFonts.cairo(fontSize: 16)),
      subtitle: Text('السعر: ${sport.price.toStringAsFixed(2)} دينار', style: GoogleFonts.cairo(fontSize: 14)),
      leading: Icon(Icons.sports, color: Theme.of(context).primaryColor),
    );
  }

  Widget _buildAdditionalInfo(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('معلومات إضافية', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.calendar_today, 'تاريخ الإنشاء:', DateFormat('yyyy-MM-dd').format(client.createdAt), context),
            if (client.assignedTrainerId != null) ...[
              const SizedBox(height: 8),
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('trainers').doc(client.assignedTrainerId).get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text('خطأ في تحميل بيانات المدرب', style: GoogleFonts.cairo(color: Colors.red));
                  }
                  if (snapshot.hasData && snapshot.data!.exists) {
                    final trainerData = snapshot.data!.data() as Map<String, dynamic>;
                    final trainerName = '${trainerData['firstName']} ${trainerData['lastName']}';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(Icons.person, 'المدرب المعين:', trainerName, context),
                        const SizedBox(height: 4),
                        _buildInfoRow(Icons.email, 'بريد المدرب:', trainerData['email'], context),
                        const SizedBox(height: 4),
                        _buildInfoRow(Icons.phone, 'هاتف المدرب:', trainerData['phoneNumber'], context),
                      ],
                    );
                  } else {
                    return Text('لم يتم العثور على بيانات المدرب', style: GoogleFonts.cairo(color: Colors.orange));
                  }
                },
              ),
            ],
            if (client.clientIds != null && client.clientIds!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow(Icons.group, 'عدد العملاء:', client.clientIds!.length.toString(), context),
              const SizedBox(height: 8),
              Text('الرياضات التي يدربها:', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: client.sports.map((sport) =>
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 4),
                      child: Text(
                        '• ${sport.name}',
                        style: GoogleFonts.cairo(fontSize: 14),
                      ),
                    )
                ).toList(),
              ),
            ],
            if (client.notes != null && client.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow(Icons.note, 'ملاحظات:', client.notes!, context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMembershipInfo(BuildContext context, bool isExpired) {
    final expirationDate = DateFormat('yyyy-MM-dd').format(client.membershipExpiration);
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

  Widget _buildActionButtons(BuildContext context, bool isExpired) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            context: context,
            icon: Icons.email,
            label: 'البريد',
            onPressed: () => _launchEmail(context, client.email),
            color: Colors.blue,
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            context: context,
            icon: Icons.call,
            label: 'اتصال',
            onPressed: () => _launchCall(context, client.phoneNumber),
            color: Colors.green,
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            context: context,
            icon: Icons.refresh,
            label: 'تجديد',
            onPressed: isExpired
                ? () => _renewMembership(context)
                : () => _showMembershipActiveMessage(context),
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white, size: 18),
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontFamily: 'Cairo', fontSize: 12),
      ),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }


  Widget _buildInfoRow(IconData icon, String label, String value, BuildContext context) {
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
                    color: Theme.of(context).colorScheme.onBackground, // Using onBackground from theme
                  ),
                ),
              ],
            ),
            overflow: TextOverflow.ellipsis, // Ensures the text doesn't overflow
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

  void _renewMembership(BuildContext context) async {
    DateTime newExpirationDate = DateTime.now().add(Duration(days: 30));
    double renewalFee = client.totalSportPrices();

    try {
      // Update Firestore
      await FirebaseFirestore.instance.collection('clients').doc(client.id).update({
        'membershipExpiration': Timestamp.fromDate(newExpirationDate),
        'paymentDates': FieldValue.arrayUnion([Timestamp.fromDate(DateTime.now())]),
        'totalPaid': FieldValue.increment(renewalFee),
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تجديد العضوية حتى ${newExpirationDate.toLocal().toString().split(' ')[0]}')),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل تجديد العضوية: $e')),
      );
    }
  }

}