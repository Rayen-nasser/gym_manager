import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../model/client.dart';

class ClientCartWidget extends StatelessWidget {
  final Client client;

  const ClientCartWidget({
    Key? key,
    required this.client,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    bool isMembershipExpired = client.membershipExpiration.isBefore(DateTime.now());

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.symmetric(vertical: (isTablet ? 10 : 12), horizontal: (isTablet ? 16 : 0)),
      child: InkWell(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, isMembershipExpired, isTablet),
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(isTablet ? 20 : 16), // Adjust padding for tablets
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isTablet) ...[
                        _buildInfoRow(Icons.email, 'البريد الإلكتروني:', client.email, context),
                        const SizedBox(height: 8),
                        _buildInfoRow(Icons.phone, 'رقم الهاتف:', client.phoneNumber, context),
                        const SizedBox(height: 8),
                      ],
                      _buildMembershipInfo(context, isMembershipExpired),
                      const SizedBox(height: 16),
                      _buildTotalPaid(context, isTablet), // Pass isTablet here
                      const SizedBox(height: 16),
                      _buildActionButtons(context, isMembershipExpired),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMembershipExpired, bool isTablet) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${client.firstName} ${client.lastName}',
                  style: TextStyle(
                    fontSize: isTablet ? 24 : 20, // Adjust font size for tablets
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Cairo',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                _buildMembershipStatus(isMembershipExpired),
              ],
            ),
          ),
        ],
      ),
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
