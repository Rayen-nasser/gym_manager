import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gym_energy/widgets/text_flied.dart';
import 'package:provider/provider.dart';

import '../../localization.dart';
import '../../model/member.dart';
import '../../model/sport.dart';
import '../../provider/members_provider.dart';
import 'member_detail_screen.dart';

class AddEditMemberScreen extends StatefulWidget {
  final Member? member;
  const AddEditMemberScreen({Key? key, this.member}) : super(key: key);

  @override
  State<AddEditMemberScreen> createState() => _AddEditMemberScreenState();
}

class _AddEditMemberScreenState extends State<AddEditMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now(); // Initialize to current date


  DateTime _membershipExpiration = DateTime.now().add(const Duration(days: 30)) ;
  String _selectedMemberType = "client";
  String? _selectedTrainerId;
  List<Sport> _selectedSports = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // If member data is passed, initialize the form fields for editing
    if (widget.member != null) {
      _firstNameController.text = widget.member!.firstName;
      _lastNameController.text = widget.member!.lastName;
      _emailController.text = widget.member!.email ?? ''; // Change made here
      _phoneController.text = widget.member!.phoneNumber ?? ''; // Change made here
      _notesController.text = widget.member!.notes ?? '';
      _selectedMemberType = widget.member!.memberType;
      _membershipExpiration = widget.member!.membershipExpiration;
      _selectedTrainerId = widget.member!.assignedTrainerId ?? '';
      _selectedSports = widget.member!.sports ?? [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          Localization.membershipTranslations['new_client'] ?? 'عميل جديد',
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final isTablet = constraints.maxWidth >= 600;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? constraints.maxWidth * 0.05 : 16.0,
                vertical: 16.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Existing fields...
                    if (isTablet)
                      _buildTabletLayout(constraints)
                    else
                      _buildPhoneLayout(),
                    const SizedBox(height: 24),

                    // Date picker field
                    _buildDateSelector(context),

                    const SizedBox(height: 24),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "تاريخ الإنشاء: ${_selectedDate.toLocal().toString().split(' ')[0]}",
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right, // Align text to the right
                ),
              ),
              Icon(Icons.calendar_today),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabletLayout(BoxConstraints constraints) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column for personal information
        Expanded(
          flex: 3,
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.all(16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Membership type selection
                  _buildTypeSelection(context),

                  const SizedBox(height: 24),

                  // Personal information form
                  _buildPersonalInfo(),
                ],
              ),
            ),
          ),
        ),
        // Right column for subscription details
        Expanded(
          flex: 2,
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sports selection
                  _buildSportsSelection(),

                  // Conditional rendering based on member type
                  if (_selectedMemberType == "client") ...[
                    const SizedBox(height: 16),
                    _buildTrainerSelection(),
                  ],
                  const SizedBox(height: 24),
                  // Additional notes section
                  _buildNotes(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneLayout() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: 20.0), // Add padding to the layout
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align children to the start
        children: [
          _buildTypeSelection(context),
          const SizedBox(height: 16),
          _buildPersonalInfo(),
          const SizedBox(height: 16),
          _buildSportsSelection(),
          if (_selectedMemberType == "client") ...[
            const SizedBox(height: 16),
            _buildTrainerSelection(),
          ],
          const SizedBox(height: 16),
          _buildNotes(),
        ],
      ),
    );
  }

  Widget _buildTypeSelection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title for the membership type selection
        Text(
          Localization.membershipTranslations['membership_type'] ?? 'Membership Type',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color, // Theme color for text
          ),
        ),
        const SizedBox(height: 12), // Spacing between title and segmented button
        // Segmented button for selecting membership type
        SegmentedButton<String>(
          segments: [
            ButtonSegment(
              value: 'trainer', // Use string value for 'trainer'
              label: Text(
                Localization.membershipTranslations['trainer'] ?? 'Trainer',
                style: TextStyle(
                  fontFamily: 'Cairo', // Cairo font for Arabic support
                  fontWeight: FontWeight.w700, // Semi-bold text
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyLarge?.backgroundColor, // Theme-based color
                ),
              ),
              icon: const Icon(Icons.person), // Trainer icon
            ),
            ButtonSegment(
              value: 'client', // Use string value for 'client'
              label: Text(
                Localization.membershipTranslations['client'] ?? 'Client',
                style: TextStyle(
                  fontFamily: 'Cairo', // Cairo font
                  fontWeight: FontWeight.w600, // Slightly less bold
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyLarge?.backgroundColor, // Theme-based color
                ),
              ),
              icon: const Icon(Icons.fitness_center), // Client icon
            ),
          ],
          selected: {_selectedMemberType}, // Track the selected value
          onSelectionChanged: (Set<String> selection) {
            setState(() {
              _selectedMemberType = selection.first; // Update the selected type

              // Additional logic based on selection
              if (_selectedMemberType == 'trainer') {
                _selectedTrainerId = null; // Reset trainer ID if selecting a trainer
                // You can add any logic here specific to trainers
              } else if (_selectedMemberType == 'client') {
                _selectedTrainerId = null; // Additional logic for clients (if necessary)
              }
            });
          },
          style: ButtonStyle(
            // Button background color based on the selected state
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                if (states.contains(MaterialState.selected)) {
                  return Theme.of(context).colorScheme.primary; // Gym's theme primary color
                }
                return Colors.grey.shade200; // Default background color for unselected
              },
            ),
            // Button text color based on the selected state
            foregroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                if (states.contains(MaterialState.selected)) {
                  return Colors.white; // White text for selected button
                }
                return Colors.black87; // Default text color for unselected
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Localization.membershipTranslations['personal_info']!,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.color, // Theme-based text color
            ),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _firstNameController,
            label: Localization.membershipTranslations['first_name']!,
            icon: Icons.person_outline,
            validator: (value) => value?.isEmpty ?? true
                ? Localization.membershipTranslations['enter_first_name']
                : null,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _lastNameController,
            label: Localization.membershipTranslations['last_name']!,
            icon: Icons.person_outline,
            validator: (value) => value?.isEmpty ?? true
                ? Localization.membershipTranslations['enter_last_name']
                : null,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _emailController,
            label: Localization.membershipTranslations['email']!,
            icon: Icons.email_outlined,
            validator: (value) {
              // Allow empty email but validate if provided
              if (value != null && value.isNotEmpty) {
                if (!value.contains('@')) {
                  return Localization.membershipTranslations['enter_valid_email'];
                }
              }
              return null; // Return null if no error
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _phoneController,
            label: Localization.membershipTranslations['phone']!,
            icon: Icons.phone_outlined,
            validator: (value) {
              // Validate that the phone number has exactly 8 characters if provided
              if (value != null && value.isNotEmpty) {
                if (value.length != 8) {
                  return Localization.membershipTranslations['phone_length_error']; // Add this translation in your localization
                }
              }
              return null; // Return null if no error
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSportsSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _selectedMemberType == "client"
              ? Localization.membershipTranslations['sports_to_teach']!
              : Localization.membershipTranslations['sports_to_join']!,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('sports').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: snapshot.data!.docs.map((doc) {
                var sport = Sport.fromMap(doc.data() as Map<String, dynamic>, doc.id);
                bool isSelected = _selectedSports.any((s) => s.id == sport.id);

                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        sport.name,
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _selectedSports.add(sport);
                      } else {
                        _selectedSports.removeWhere((s) => s.id == sport.id);
                      }
                      // Reset trainer selection when sports change
                      _selectedTrainerId = null;
                    });
                  },
                  backgroundColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.grey[200],
                  selectedColor: Theme.of(context).colorScheme.primary,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                );
              }).toList(),
            );
          },
        ),
        if (_selectedSports.isEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              Localization.membershipTranslations['select_sport']!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTrainerSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Localization.membershipTranslations['select_trainer']!,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('trainers').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            List<DropdownMenuItem<String>> trainerItems = [];
            String? validTrainerId;

            for (var doc in snapshot.data!.docs) {
              var data = doc.data() as Map<String, dynamic>;
              List<dynamic> trainerSportsData = data['sports'] ?? [];
              List<String> trainerSports = trainerSportsData.map((sport) {
                if (sport is Map<String, dynamic>) {
                  return sport['id'] as String;
                }
                return '';
              }).toList();

              // Check if the trainer can teach any of the selected sports
              bool canTeach = _selectedSports.any((sport) => trainerSports.contains(sport.id));

              if (canTeach) {
                trainerItems.add(DropdownMenuItem(
                  value: doc.id,
                  child: Text(
                    '${data['firstName']} ${data['lastName']}',
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                ));

                // Set the first valid trainer as the default selected trainer
                if (validTrainerId == null) {
                  validTrainerId = doc.id;
                }
              }
            }

            // Check if the selected trainer exists in the filtered list
            if (trainerItems.isEmpty || !_selectedSports.any((sport) => trainerItems.any((item) => item.value == _selectedTrainerId))) {
              _selectedTrainerId = null;
            } else if (_selectedTrainerId == null) {
              _selectedTrainerId = validTrainerId;
            }

            return DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: Localization.membershipTranslations['choose_trainer'],
                labelStyle: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                prefixIcon: Icon(Icons.fitness_center,
                    color: Theme.of(context).iconTheme.color),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[850]
                    : Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5),
                  ),
                ),
                errorStyle: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  color: Colors.red,
                ),
              ),
              value: _selectedTrainerId,
              items: trainerItems.isNotEmpty ? trainerItems : null,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedTrainerId = newValue;
                });
              },
              validator: (value) {
                bool isBodyBuildingSelected = _selectedSports.any(
                      (sport) => sport.name == 'كمال الأجسام',
                );

                if (isBodyBuildingSelected) {
                  return null;
                }

                if (value == null && _selectedSports.isNotEmpty) {
                  return Localization.membershipTranslations['choose_trainer'];
                }

                return null;
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildNotes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Localization.membershipTranslations['additional_notes']!,
          style: TextStyle(
            fontSize: 20, // Slightly larger for better emphasis
            fontWeight: FontWeight.bold,
            color: Theme.of(context)
                .textTheme
                .titleLarge
                ?.color, // Using primary color for theme
          ),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _notesController,
          label: Localization.membershipTranslations['notes']!,
          icon: Icons.note_outlined,
          validator: (value) {
            // Define your validation logic if needed, or return null if validation is not required
            return null;
          },
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return FilledButton.icon(
      onPressed: _isLoading ? null : _submitForm, // Disable button when loading
      style: FilledButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      label: _isLoading
          ? SizedBox(
              width: 16, // Adjust width to center spinner
              height: 16, // Adjust height to center spinner
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(
              Localization.membershipTranslations['add_client_button']!,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Cairo', // Use Cairo font family
              ),
            ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000), // Optional: Set a minimum date
      lastDate: DateTime(2101), // Optional: Set a maximum date
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _membershipExpiration = _selectedDate.add(const Duration(days: 30));
      print(_membershipExpiration.month);
    }
  }


  // Function to show a flushbar
  void _showFlushBar(String message, Color color) {
    Flushbar(
      message: message,
      duration: Duration(seconds: 3),
      backgroundColor: color,
    ).show(context);
  }

  // Function to submit a Member
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      _showFlushBar(
        Localization.membershipTranslations['fill_required']!,
        Colors.red,
      );
      return;
    }

    if (_selectedSports.isEmpty) {
      _showFlushBar(
        Localization.membershipTranslations['select_sport']!,
        Colors.red,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final email = _emailController.text.trim();
      final phoneNumber = _phoneController.text.trim();

      // Check for existing members with the same first name and last name
      final existingMembers = await FirebaseFirestore.instance
          .collection('clients')
          .where('firstName', isEqualTo: firstName)
          .where('lastName', isEqualTo: lastName)
          .get();

      if (existingMembers.docs.isNotEmpty &&
          (widget.member == null ||
              (widget.member != null &&
                  (widget.member!.firstName != firstName ||
                      widget.member!.lastName != lastName)))) {
        _showFlushBar('هذا العضو موجود بالفعل.', Colors.red);
        return;
      }

      // Check for existing email if it is provided
      if (widget.member == null && email.isNotEmpty) {
        final emailCheck = await FirebaseFirestore.instance
            .collection('clients')
            .where('email', isEqualTo: email)
            .get();

        if (emailCheck.docs.isNotEmpty) {
          _showFlushBar('يجب أن يكون البريد الإلكتروني فريدًا.', Colors.red);
          return;
        }
      }

      // Check for existing phone number if it is provided
      if (widget.member == null && phoneNumber.isNotEmpty) {
        final phoneCheck = await FirebaseFirestore.instance
            .collection('clients')
            .where('phoneNumber', isEqualTo: phoneNumber)
            .get();

        if (phoneCheck.docs.isNotEmpty) {
          _showFlushBar('يجب أن يكون رقم الهاتف فريدًا.', Colors.red);
          return;
        }
      }

      // Calculate the total paid based on selected sports asynchronously
      double totalPaid = await _calculateTotalPaid(_selectedSports);

      // Create the Member object
      final member = Member(
        id: widget.member?.id ?? '',
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        createdAt: _selectedDate,
        membershipExpiration: _membershipExpiration,
        totalPaid: widget.member != null ? totalPaid : 0,
        paymentDates: widget.member?.paymentDates ?? [],
        sports: _selectedSports,
        clientIds: widget.member?.clientIds ?? [],
        notes: _notesController.text,
        memberType: _selectedMemberType,
        assignedTrainerId: _selectedTrainerId != null && _selectedTrainerId!.isNotEmpty
            ? _selectedTrainerId
            : 'none',
      );

      WriteBatch batch = FirebaseFirestore.instance.batch();
      late DocumentReference memberRef;

      if (widget.member == null) {
        // Add a new member (trainer or client) using batched write
        if (member.memberType == 'trainer') {
          memberRef = FirebaseFirestore.instance.collection('trainers').doc();
        } else {
          memberRef = FirebaseFirestore.instance.collection('clients').doc();
        }

        batch.set(memberRef, member.toMap());

        // Add client to the trainer if a trainer is selected
        if (_selectedTrainerId != null) {
          batch.update(
            FirebaseFirestore.instance.collection('trainers').doc(_selectedTrainerId),
            {'clientIds': FieldValue.arrayUnion([memberRef.id])},
          );
          await _addClientToTrainer(memberRef.id, _selectedTrainerId!);
        }
      } else {
        // Edit existing member using batched write
        if (member.memberType == 'trainer') {
          memberRef = FirebaseFirestore.instance.collection('trainers').doc(widget.member!.id);
        } else {
          memberRef = FirebaseFirestore.instance.collection('clients').doc(widget.member!.id);
        }

        DocumentSnapshot memberDoc = await memberRef.get();
        if (!memberDoc.exists) {
          _showFlushBar('لم يتم العثور على مستند العضو.', Colors.red);
          return;
        }

        batch.update(memberRef, member.toMap());

        if (_selectedTrainerId != null) {
          batch.update(
            FirebaseFirestore.instance.collection('trainers').doc(_selectedTrainerId),
            {'clientIds': FieldValue.arrayUnion([widget.member!.id])},
          );
          await _addClientToTrainer(widget.member!.id, _selectedTrainerId!);
        }
      }

      // Commit the batch write
      await batch.commit();

      // Fetch the updated document to get the latest data
      final updatedDoc = await memberRef.get();
      final updatedMember = Member.fromMap(
        updatedDoc.data() as Map<String, dynamic>,
        updatedDoc.id,
      );

      Provider.of<MembersProvider>(context, listen: false).addMember(updatedMember);

      _showFlushBar(Localization.membershipTranslations['success']!, Colors.green);

      // Navigate to the member detail screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MemberDetailScreen(
            memberId: updatedMember.id,
            backToListMember: true,
          ),
        ),
      );
    } catch (e) {
      _showFlushBar('${Localization.membershipTranslations['error']}: $e', Colors.red);
      print('Error occurred: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }


  // Function to calculate the total paid based on selected sports
  Future<double> _calculateTotalPaid(List<Sport> selectedSports) async {
    double total = 0.0;

    // Assuming you have a way to get the price for each sport
    for (var sport in selectedSports) {
      total += sport.price; // Directly summing up the prices
    }

    return total;
  }

  // Function to add the client ID to the trainer's client list
  Future<void> _addClientToTrainer(String clientId, String trainerId) async {
    // Update the trainer's document with the new client ID
    await FirebaseFirestore.instance
        .collection('trainers')
        .doc(trainerId)
        .update({
      'clientIds':
          FieldValue.arrayUnion([clientId]), // Add client ID to the list
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
