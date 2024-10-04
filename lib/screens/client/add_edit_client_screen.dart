import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Import this for date initialization

class AddClientScreen extends StatefulWidget {
  const AddClientScreen({Key? key}) : super(key: key);

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  final _paymentController = TextEditingController();

  MemberType _selectedMemberType = MemberType.personal;
  DateTime _membershipExpiration = DateTime.now().add(const Duration(days: 30));
  String? _selectedTrainerId;
  List<Sport> _selectedSports = [];
  bool _isLoading = false;

  // Theme colors
  final primaryColor = Colors.blue.shade800;
  final secondaryColor = Colors.blue.shade100;

  // Arabic translations
  final translations = {
    'new_client': 'إضافة عميل جديد',
    'loading': 'جاري المعالجة...',
    'membership_type': 'نوع العضوية',
    'trainee': 'متدرب',
    'trainer': 'مدرب',
    'personal_info': 'المعلومات الشخصية',
    'first_name': 'الاسم الأول',
    'last_name': 'اسم العائلة',
    'email': 'البريد الإلكتروني',
    'phone': 'رقم الهاتف',
    'enter_first_name': 'الرجاء إدخال الاسم الأول',
    'enter_last_name': 'الرجاء إدخال اسم العائلة',
    'enter_email': 'الرجاء إدخال البريد الإلكتروني',
    'enter_valid_email': 'الرجاء إدخال بريد إلكتروني صحيح',
    'enter_phone': 'الرجاء إدخال رقم الهاتف',
    'membership_details': 'تفاصيل العضوية',
    'expiry_date': 'تاريخ انتهاء العضوية',
    'initial_payment': 'مبلغ الدفع الأولي',
    'currency': 'ر.س',
    'enter_amount': 'الرجاء إدخال مبلغ الدفع',
    'enter_valid_amount': 'الرجاء إدخال مبلغ صحيح',
    'select_trainer': 'اختيار المدرب',
    'choose_trainer': 'الرجاء اختيار المدرب',
    'sports_to_teach': 'الرياضات التي يقوم بتدريبها',
    'sports_to_join': 'الرياضات المراد الاشتراك بها',
    'select_sport': 'الرجاء اختيار رياضة واحدة على الأقل',
    'additional_notes': 'ملاحظات إضافية',
    'notes': 'ملاحظات',
    'add_notes': 'أضف أي ملاحظات إضافية هنا',
    'add_client_button': 'إضافة العميل',
    'fill_required': 'الرجاء تعبئة جميع الحقول المطلوبة',
    'success': 'تمت إضافة العميل بنجاح',
    'error': 'حدث خطأ أثناء إضافة العميل',
  };

  @override
  void initState() {
    super.initState();
    // Initialize date formatting for the current locale
    initializeDateFormatting('ar', null).then((_) {
      setState(() {
        // Now you can safely use DateFormat here or in other parts of the widget.
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen size
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          translations['new_client'] ?? 'عميل جديد',
        ),
      ),
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: primaryColor),
            const SizedBox(height: 16),
            Text(translations['loading']!),
          ],
        ),
      )
          : Theme(
        data: Theme.of(context).copyWith(
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? constraints.maxWidth * 0.1 : 16.0,
                  vertical: 16.0,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (isTablet) _buildTabletLayout() else _buildPhoneLayout(),
                      const SizedBox(height: 24),
                      _buildSubmitButton(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  _buildTypeSelection(),
                  const SizedBox(height: 16),
                  _buildPersonalInfo(),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  _buildMembershipDetails(),
                  if (_selectedMemberType == MemberType.personal) ...[
                    const SizedBox(height: 16),
                    _buildTrainerSelection(),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSportsSelection(),
        const SizedBox(height: 16),
        _buildNotes(),
      ],
    );
  }

  Widget _buildPhoneLayout() {
    return Column(
      children: [
        _buildTypeSelection(),
        const SizedBox(height: 16),
        _buildPersonalInfo(),
        const SizedBox(height: 16),
        _buildMembershipDetails(),
        if (_selectedMemberType == MemberType.personal) ...[
          const SizedBox(height: 16),
          _buildTrainerSelection(),
        ],
        const SizedBox(height: 16),
        _buildSportsSelection(),
        const SizedBox(height: 16),
        _buildNotes(),
      ],
    );
  }

  Widget _buildTypeSelection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              translations['membership_type']!,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                return SegmentedButton<MemberType>(
                  segments: [
                    ButtonSegment(
                      value: MemberType.personal,
                      label: Text(translations['trainee']!),
                      icon: const Icon(Icons.person),
                    ),
                    ButtonSegment(
                      value: MemberType.trainer,
                      label: Text(translations['trainer']!),
                      icon: const Icon(Icons.fitness_center),
                    ),
                  ],
                  selected: {_selectedMemberType},
                  onSelectionChanged: (Set<MemberType> selection) {
                    setState(() {
                      _selectedMemberType = selection.first;
                      if (_selectedMemberType == MemberType.trainer) {
                        _selectedTrainerId = null;
                      }
                    });
                  },
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all(
                      Size.fromHeight(constraints.maxWidth > 300 ? 48 : 40),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfo() {
    return Card(
      elevation: 4,
      color: Theme.of(context).cardColor, // Use theme card color
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              translations['personal_info']!,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color, // Theme-based text color
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _firstNameController,
              label: translations['first_name']!,
              icon: Icons.person_outline,
              validator: (value) => value?.isEmpty ?? true ? translations['enter_first_name'] : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _lastNameController,
              label: translations['last_name']!,
              icon: Icons.person_outline,
              validator: (value) => value?.isEmpty ?? true ? translations['enter_last_name'] : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _emailController,
              label: translations['email']!,
              icon: Icons.email_outlined,
              validator: (value) {
                if (value?.isEmpty ?? true) return translations['enter_email'];
                if (!value!.contains('@')) return translations['enter_valid_email'];
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _phoneController,
              label: translations['phone']!,
              icon: Icons.phone_outlined,
              validator: (value) => value?.isEmpty ?? true ? translations['enter_phone'] : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).iconTheme.color), // Theme-based icon color
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[850] // Dark mode fill color
            : Colors.grey[200], // Light mode fill color
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).dividerColor), // Theme-based border color
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.5)), // Lighter border
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2), // Focused border color
        ),
        labelStyle: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color, // Theme-based label color
        ),
      ),
      validator: validator,
    );
  }


  Widget _buildMembershipDetails() {
    return Card(
      elevation: 2,
      color: Theme.of(context).cardColor, // Use theme card color
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              translations['membership_details']!,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color, // Theme-based text color
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _membershipExpiration,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                );
                if (picked != null) {
                  setState(() => _membershipExpiration = picked);
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: translations['expiry_date'],
                  prefixIcon: Icon(Icons.calendar_today, color: Theme.of(context).iconTheme.color), // Theme-based icon color
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[850] // Dark mode fill color
                      : Colors.grey[200], // Light mode fill color
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Theme.of(context).dividerColor), // Theme-based border color
                  ),
                ),
                child: Text(
                  DateFormat('yyyy/MM/dd', 'en').format(_membershipExpiration),
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color, // Theme-based text color
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _paymentController,
              decoration: InputDecoration(
                labelText: translations['initial_payment'],
                prefixIcon: Icon(Icons.payments_outlined, color: Theme.of(context).iconTheme.color), // Theme-based icon color
                suffixText: translations['currency'],
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[850] // Dark mode fill color
                    : Colors.grey[200], // Light mode fill color
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).dividerColor), // Theme-based border color
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.5)), // Lighter border
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2), // Focused border color
                ),
                errorStyle: TextStyle(
                  color: Theme.of(context).colorScheme.error, // Error color based on theme
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) return translations['enter_amount'];
                if (double.tryParse(value!) == null) {
                  return translations['enter_valid_amount'];
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainerSelection() {
    return Card(
      elevation: 2,
      color: Theme.of(context).cardColor, // Use theme card color
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              translations['select_trainer']!,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color, // Theme-based text color
              ),
            ),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('clients')
                  .where('memberType', isEqualTo: MemberType.trainer.toString())
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                List<DropdownMenuItem<String>> trainerItems = [];
                for (var doc in snapshot.data!.docs) {
                  var data = doc.data() as Map<String, dynamic>;
                  trainerItems.add(DropdownMenuItem(
                    value: doc.id,
                    child: Text('${data['firstName']} ${data['lastName']}',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color, // Theme-based text color
                      ),
                    ),
                  ));
                }

                return DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: translations['choose_trainer'],
                    labelStyle: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color, // Theme-based label color
                    ),
                    prefixIcon: Icon(Icons.fitness_center, color: Theme.of(context).iconTheme.color), // Theme-based icon color
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[850] // Dark mode fill color
                        : Colors.grey[200], // Light mode fill color
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Theme.of(context).dividerColor), // Theme-based border color
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.5)), // Lighter border
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2), // Focused border color
                    ),
                    errorStyle: TextStyle(
                      color: Theme.of(context).colorScheme.error, // Error color based on theme
                    ),
                  ),
                  value: _selectedTrainerId,
                  items: trainerItems,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedTrainerId = newValue;
                    });
                  },
                  validator: (value) =>
                  value == null ? translations['choose_trainer'] : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSportsSelection() {
    return Card(
      elevation: 2,
      color: Theme.of(context).cardColor, // Use theme card color
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _selectedMemberType == MemberType.trainer
                  ? translations['sports_to_teach']!
                  : translations['sports_to_join']!,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color, // Theme-based text color
              ),
            ),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('sports').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: snapshot.data!.docs.map((doc) {
                        var sport = Sport.fromMap(doc.data() as Map<String, dynamic>);
                        bool isSelected = _selectedSports.any((s) => s.id == sport.id);

                        return ChoiceChip(
                          label: Text(
                            sport.name,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) {
                                _selectedSports.add(sport);
                              } else {
                                _selectedSports.removeWhere((s) => s.id == sport.id);
                              }
                            });
                          },
                          backgroundColor: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[800] // Dark mode background color for chips
                              : Colors.grey.shade50, // Light mode background color for chips
                          selectedColor: secondaryColor,
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList(),
                    );
                  },
                );
              },
            ),
            if (_selectedSports.isEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  translations['select_sport']!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error, // Use theme error color
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotes() {
    return Card(
      elevation: 2,
      color: Theme.of(context).cardColor, // Use theme card color
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              translations['additional_notes']!,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color, // Theme-based text color
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: translations['notes'],
                prefixIcon: Icon(Icons.note_outlined, color: Theme.of(context).iconTheme.color), // Theme-based icon color
                hintText: translations['add_notes'],
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[850] // Dark mode fill color
                    : Colors.grey[200], // Light mode fill color
              ),
              maxLines: 3,
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSubmitButton() {
    return FilledButton.icon(
      onPressed: _submitForm,
      style: FilledButton.styleFrom(
        backgroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      icon: const Icon(Icons.add, color: Colors.white),
      label: Text(
        translations['add_client_button']!,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(translations['fill_required']!),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedSports.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(translations['select_sport']!),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final client = Client(
        id: '', // Will be set by Firestore
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        phoneNumber: _phoneController.text,
        createdAt: DateTime.now(),
        membershipExpiration: _membershipExpiration,
        memberType: _selectedMemberType,
        totalPaid: double.parse(_paymentController.text),
        paymentDates: [DateTime.now()],
        nextPaymentDate: DateTime.now().add(const Duration(days: 30)),
        sports: _selectedSports,
        assignedTrainerId:
        _selectedMemberType == MemberType.personal ? _selectedTrainerId : null,
        clientIds: _selectedMemberType == MemberType.trainer ? [] : null,
        notes: _notesController.text,
      );

      // Add to Firestore
      await FirebaseFirestore.instance
          .collection('clients')
          .add(client.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(translations['success']!),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text('${translations['error']}: $e'),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    _paymentController.dispose();
    super.dispose();
  }
}

// Add these enums and models if you don't have them already

enum MemberType {
  personal,
  trainer,
}

class Sport {
  final String id;
  final String name;
  final double price;

  Sport({
    required this.id,
    required this.name,
    required this.price,
  });

  factory Sport.fromMap(Map<String, dynamic> map) {
    return Sport(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
    };
  }
}

class Client {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final DateTime createdAt;
  final DateTime membershipExpiration;
  final MemberType memberType;
  final double totalPaid;
  final List<DateTime> paymentDates;
  final DateTime nextPaymentDate;
  final List<Sport> sports;
  final String? assignedTrainerId;
  final List<String>? clientIds;
  final String notes;

  Client({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.createdAt,
    required this.membershipExpiration,
    required this.memberType,
    required this.totalPaid,
    required this.paymentDates,
    required this.nextPaymentDate,
    required this.sports,
    this.assignedTrainerId,
    this.clientIds,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt.toIso8601String(),
      'membershipExpiration': membershipExpiration.toIso8601String(),
      'memberType': memberType.toString(),
      'totalPaid': totalPaid,
      'paymentDates': paymentDates.map((date) => date.toIso8601String()).toList(),
      'nextPaymentDate': nextPaymentDate.toIso8601String(),
      'sports': sports.map((sport) => sport.toMap()).toList(),
      'assignedTrainerId': assignedTrainerId,
      'clientIds': clientIds,
      'notes': notes,
    };
  }
}