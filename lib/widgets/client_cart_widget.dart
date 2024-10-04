import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/client.dart';

class MemberCartWidget extends StatelessWidget {
  final Client client;
  final double totalPaid; // Add a property for total paid

  const MemberCartWidget({
    Key? key,
    required this.client,
    required this.totalPaid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Member Information
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
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'رقم الهاتف: ${client.phoneNumber}',
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'تاريخ انتهاء العضوية: ${client.membershipExpiration.toLocal().toString().split(' ')[0]}',
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 16),

              // Total Paid Information
              Text(
                'إجمالي المدفوع: ${totalPaid.toStringAsFixed(2)} ر.س',
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
                      onPressed: () {
                        // Renew plan action
                      },
                      context: context,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _launchEmail(BuildContext context, String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Your Subject Here', // Optional: Add subject
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No email client found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch email app: $e')),
      );
    }
  }

  void _launchCall(BuildContext context, String phoneNumber) async {
    final Uri callUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      throw 'Could not launch phone app';
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
          icon: Icon(icon, color: Theme.of(context).primaryColor),
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
