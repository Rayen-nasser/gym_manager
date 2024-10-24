import 'package:another_flushbar/flushbar.dart';
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

class MemberDetailScreen extends StatefulWidget {
  final String memberId;
  final bool? backToListMember;
  final bool? fromEditScreen;

  const MemberDetailScreen({
    Key? key,
    required this.memberId,
    this.backToListMember,
    this.fromEditScreen,
  }) : super(key: key);

  @override
  State<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Consumer<MembersProvider>(
      builder: (context, provider, child) {
        // Find the member in all members first, not just filtered
        late Member? member;
        try {
          member = provider.filteredMembers.firstWhere(
            (m) => m.id == widget.memberId,
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
            leading: widget.backToListMember == true
                ? IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                // Pops the current screen off the stack
                if(widget.fromEditScreen == true){
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                }

              },
            )
                : null,
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

                  // Show _buildContactInfo only if at least one of email or phoneNumber is not empty
                  if (member.email != null && member.email!.isNotEmpty ||
                      member.phoneNumber != null && member.phoneNumber!.isNotEmpty)
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
                  _buildActionButtons(context, isExpired, member, provider),
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
      Navigator.of(context).pop(); // Close any dialog if open

      Flushbar(
        title: member.isActive ? 'نجاح الحظر' : 'نجاح إلغاء الحظر',
        message: member.isActive
            ? 'تم حظر العضو: ${member.fullName}'
            : 'تم إلغاء حظر العضو: ${member.fullName}',
        flushbarStyle: FlushbarStyle.GROUNDED,
        backgroundColor: member.isActive ? Colors.red : Colors.green,
        duration: Duration(seconds: 3),
        titleText: Text(
          member.isActive ? 'نجاح الحظر' : 'نجاح إلغاء الحظر',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        messageText: Text(
          member.isActive
              ? 'تم حظر العضو: ${member.fullName}'
              : 'تم إلغاء حظر العضو: ${member.fullName}',
          style: GoogleFonts.cairo(
            color: Colors.white,
          ),
        ),
      ).show(context);
    } catch (e) {
      Flushbar(
        title: 'خطأ',
        message: 'حدث خطأ أثناء حظر/إلغاء حظر العضو: $e',
        flushbarStyle: FlushbarStyle.GROUNDED,
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        titleText: Text(
          'خطأ',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        messageText: Text(
          'حدث خطأ أثناء حظر/إلغاء حظر العضو: $e',
          style: GoogleFonts.cairo(
            color: Colors.white,
          ),
        ),
      ).show(context);
    }
  }

  void _deleteMember(BuildContext context, Member client) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('تأكيد الحذف', style: GoogleFonts.cairo()),
          content: Text(
            'هل أنت متأكد من رغبتك في حذف هذا العضو؟',
            style: GoogleFonts.cairo(),
          ),
          actions: [
            TextButton(
              child: Text('إلغاء', style: GoogleFonts.cairo()),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('حذف', style: GoogleFonts.cairo()),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Close the dialog

                try {
                  // Call the provider to delete the member
                  await Provider.of<MembersProvider>(context, listen: false)
                      .deleteMember(client);

                  // Check if the widget is still mounted before showing the Flushbar
                  if (!context.mounted) return;
                  // Show success message
                  Flushbar(
                    title: 'نجاح الحذف',
                    message: 'تم حذف العضو: ${client.fullName}',
                    flushbarStyle: FlushbarStyle.GROUNDED,
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 3),
                    titleText: Text(
                      'نجاح الحذف',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    messageText: Text(
                      'تم حذف العضو: ${client.fullName}',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                      ),
                    ),
                  ).show(context);

                } catch (error) {
                  // Check if the widget is still mounted before showing the error message
                  if (!context.mounted) return;

                  // Show error message
                  Flushbar(
                    title: 'خطأ',
                    message: 'حدث خطأ أثناء حذف العضو: ${client.fullName}',
                    flushbarStyle: FlushbarStyle.GROUNDED,
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 3),
                    titleText: Text(
                      'خطأ',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    messageText: Text(
                      'حدث خطأ أثناء حذف العضو: ${client.fullName}',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                      ),
                    ),
                  ).show(context);
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
            Text(
              'معلومات الاتصال',
              style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            // Display email only if it's not null or empty
            if (member.email != null && member.email!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow(Icons.email, 'البريد الإلكتروني:', member.email!, context),
            ],

            // Display phone number only if it's not null or empty
            if (member.phoneNumber != null && member.phoneNumber!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow(Icons.phone, 'رقم الهاتف:', member.phoneNumber!, context),
            ],
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
            if (member.paymentDates.isNotEmpty)
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
                        _buildInfoRow(
                            Icons.person, 'المدرب المعين:', trainerName, context),
                        if (trainerData['email'] != null &&
                            trainerData['email'].isNotEmpty)
                          const SizedBox(height: 4),
                        _buildInfoRow(Icons.email, 'بريد المدرب:',
                            trainerData['email'], context),
                        if (trainerData['phoneNumber'] != null)
                          const SizedBox(height: 4),
                        _buildInfoRow(Icons.phone, 'هاتف المدرب:',
                            trainerData['phoneNumber'], context),
                      ],
                    );
                  }

                  return Container();
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

            // Add Notes Section
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
      BuildContext context, bool isExpired, Member member, MembersProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (member.email != null && member.email!.isNotEmpty) // Check if email is not null or empty
            _buildActionButton(
              context: context,
              icon: Icons.email,
              label: 'البريد',
              onPressed: () => _launchEmail(context, member),
              color: Colors.blue,
            ),
          const SizedBox(width: 8),
          if (member.phoneNumber != null && member.phoneNumber!.isNotEmpty) // Check if phone number is not null or empty
            _buildActionButton(
              context: context,
              icon: Icons.call,
              label: 'اتصال',
              onPressed: () => _launchCall(context, member.phoneNumber!),
              color: Colors.green,
            ),
          const SizedBox(width: 8),
          _buildActionButton(
            context: context,
            icon: Icons.refresh,
            label: 'تجديد',
            onPressed: isExpired
                ? () => _renewMembership(context, member, provider)
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

  void _launchEmail(BuildContext context, Member member) async {
    final String subject = 'تجديد اشتراك النادي الرياضي - ${member.firstName} ${member.lastName}';

    // Format the membership expiration date
    final String formattedExpirationDate = DateFormat('yyyy-MM-dd').format(member.membershipExpiration);

    // Format the total amount paid
    final String formattedTotalPaid = member.totalSportPrices().toStringAsFixed(2);

    // Create a personalized email body
    final String body = '''
مرحباً ${member.firstName} ${member.lastName},

نود تذكيرك بأن اشتراكك في النادي الرياضي قد انتهى بتاريخ $formattedExpirationDate. حتى الآن،  المبلغ الذي يجب دفعه إجمالي قدره $formattedTotalPaid دينار.

للاستمرار في تحسين لياقتك البدنية والوصول إلى الجسم المثالي، يرجى تجديد اشتراكك.

إذا كنت بحاجة إلى أي مساعدة أو استفسارات إضافية، لا تتردد في التواصل معنا.

شكراً لاختيارك نادينا!

فريق النادي الرياضي
''';

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: member.email,
      query: 'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
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

  void _renewMembership(BuildContext context, Member member, MembersProvider provider) async {
    try {
      Member updatedMember = await provider.renewMembership(member);

      setState(() {
        member = updatedMember; // Update the member in state
      });

      // Show success message
      Flushbar(
        title: 'نجاح تجديد الاشتراك',
        message: 'تم تجديد الاشتراك بنجاح.',
        flushbarStyle: FlushbarStyle.GROUNDED,
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
        titleText: Text(
          'نجاح تجديد الاشتراك',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        messageText: Text(
          'تم تجديد الاشتراك بنجاح.',
          style: GoogleFonts.cairo(
            color: Colors.white,
          ),
        ),
      ).show(context);
    } catch (e) {
      // Show error message
      Flushbar(
        title: 'فشل تجديد الاشتراك',
        message: 'فشل تجديد الاشتراك: $e',
        flushbarStyle: FlushbarStyle.GROUNDED,
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        titleText: Text(
          'فشل تجديد الاشتراك',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        messageText: Text(
          'فشل تجديد الاشتراك: $e',
          style: GoogleFonts.cairo(
            color: Colors.white,
          ),
        ),
      ).show(context);
    }
  }

}
