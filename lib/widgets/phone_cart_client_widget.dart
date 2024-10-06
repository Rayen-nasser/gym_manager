import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/member.dart';
import '../screens/client/client_detail_screen.dart';

class PhoneCartClientWidget extends StatelessWidget {
  final Member client;

  const PhoneCartClientWidget({
    Key? key,
    required this.client,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isMembershipExpired = client.membershipExpiration.isBefore(DateTime.now());

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navigate to the client detail screen on tap
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ClientDetailScreen(client: client)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildAvatar(theme),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildName(theme),
                    const SizedBox(height: 4),
                    _buildTotalPaid(theme),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildExpirationDate(theme),
                  const SizedBox(height: 4),
                  _buildMembershipStatus(theme, isMembershipExpired),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
      child: Text(
        client.firstName[0].toUpperCase(),
        style: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildName(ThemeData theme) {
    return Text(
      '${client.firstName} ${client.lastName}',
      style: GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTotalPaid(ThemeData theme) {
    return Text(
      '${client.totalSportPrices().toStringAsFixed(2)} دينار',
      style: GoogleFonts.cairo(
        fontSize: 14,
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildExpirationDate(ThemeData theme) {
    return Text(
      DateFormat('yyyy-MM-dd').format(client.membershipExpiration),
      style: GoogleFonts.cairo(
        fontSize: 12,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildMembershipStatus(ThemeData theme, bool isExpired) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isExpired ? theme.colorScheme.error : theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isExpired ? 'منتهية' : 'نشطة',
        style: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onPrimary,
        ),
      ),
    );
  }
}
