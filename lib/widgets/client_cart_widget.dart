import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/client.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClientCartWidget extends StatelessWidget {
  final Client client;

  const ClientCartWidget({
    Key? key,
    required this.client,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isMembershipExpired = client.membershipExpiration.isBefore(DateTime.now());

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Client Information
            Text(
              '${client.firstName} ${client.lastName}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'البريد الإلكتروني: ${client.email}',
              style: const TextStyle(fontSize: 16, fontFamily: 'Cairo'),
            ),
            const SizedBox(height: 4),
            Text(
              'رقم الهاتف: ${client.phoneNumber}',
              style: const TextStyle(fontSize: 16, fontFamily: 'Cairo'),
            ),
            const SizedBox(height: 8),
            Text(
              'تاريخ انتهاء العضوية: ${client.membershipExpiration.toLocal().toString().split(' ')[0]}',
              style: TextStyle(
                fontSize: 16,
                color: isMembershipExpired ? Colors.red : Theme.of(context).colorScheme.onBackground,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 16),

            // Total Paid
            Text(
              'إجمالي المدفوع: ${client.totalSportPrices().toStringAsFixed(2)} دينار ',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 16),

            // Action Icons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _buildIconButton(
                    icon: Icons.email,
                    label: 'Email',
                    onPressed: () => _launchEmail(context, client.email),
                    context: context,
                  ),
                ),
                Expanded(
                  child: _buildIconButton(
                    icon: Icons.call,
                    label: 'Call',
                    onPressed: () => _launchCall(context, client.phoneNumber),
                    context: context,
                  ),
                ),
                Expanded(
                  child: _buildIconButton(
                    icon: Icons.refresh,
                    label: 'Renew',
                    // Disable renew button if the membership is not expired
                    onPressed: isMembershipExpired
                        ? () => _renewMembership(context)
                        : () {
                      _showMembershipActiveMessage(context);
                    },
                    context: context,
                  ),
                ),
              ],
            ),
            if (isMembershipExpired) ...[
              const SizedBox(height: 8),
              Text(
                'انتهت صلاحية العضوية!',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ],
        ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No email client found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch email app: $e')),
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

  void _launchCall(BuildContext context, String phoneNumber) async {
    final Uri callUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    try {
      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch phone app')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch phone app: $e')),
      );
    }
  }

  Widget _buildIconButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required BuildContext context,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, color: Theme.of(context).colorScheme.secondary),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }
}
