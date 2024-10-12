import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart'; // Import this for date initialization
import 'package:gym_energy/widgets/text_flied.dart';

import '../../localization.dart';
import '../../model/member.dart';
import '../../model/sport.dart';

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

  String _selectedMemberType = "client";
  DateTime _membershipExpiration = DateTime.now().add(const Duration(days: 30));
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
      _emailController.text = widget.member!.email;
      _phoneController.text = widget.member!.phoneNumber;
      _notesController.text = widget.member!.notes ?? '';
      _selectedMemberType = widget.member!.memberType;
      _membershipExpiration = widget.member!.membershipExpiration;
      _selectedTrainerId = widget.member!.assignedTrainerId;
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
                    if (isTablet)
                      _buildTabletLayout(constraints)
                    else
                      _buildPhoneLayout(),
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
                  if (_selectedMemberType == "trainer") ...[
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
          if (_selectedMemberType == "trainer") ...[
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
              value: 'client', // Use string value
              label: Text(
                Localization.membershipTranslations['client'] ?? 'Client',
                style: TextStyle(
                  fontFamily: 'Cairo', // Using Cairo font
                  fontWeight: FontWeight.w700, // Semi-bold style
                  fontSize: 16, // Adjust font size
                  color: Theme.of(context).textTheme.bodyLarge?.backgroundColor, // Theme-based color
                ),
              ),
              icon: const Icon(Icons.person),
            ),
            ButtonSegment(
              value: 'trainer', // Use string value
              label: Text(
                Localization.membershipTranslations['trainer'] ?? 'trainer',
                style: TextStyle(
                  fontFamily: 'Cairo', // Using Cairo font
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyLarge?.backgroundColor, // Theme-based color
                ),
              ),
              icon: const Icon(Icons.fitness_center),
            ),
          ],
          selected: {_selectedMemberType}, // Should still hold string value
          onSelectionChanged: (Set<String> selection) {
            setState(() {
              _selectedMemberType = selection.first; // Update selected member type
              if (_selectedMemberType == 'trainer') {
                _selectedTrainerId = null; // Reset trainer ID if selected trainer
              }
            });
          },
          style: ButtonStyle(
            // Button background color based on the selected state
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                if (states.contains(MaterialState.selected)) {
                  return Theme.of(context).colorScheme.primary; // Gym theme primary color
                }
                return Colors.grey.shade200; // Default background color
              },
            ),
            // Button text color based on the selected state
            foregroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                if (states.contains(MaterialState.selected)) {
                  return Colors.white; // White text for selected button
                }
                return Colors.black87; // Default text color
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
              if (value?.isEmpty ?? true)
                return Localization.membershipTranslations['enter_email'];
              if (!value!.contains('@'))
                return Localization.membershipTranslations['enter_valid_email'];
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _phoneController,
            label: Localization.membershipTranslations['phone']!,
            icon: Icons.phone_outlined,
            validator: (value) => value?.isEmpty ?? true
                ? Localization.membershipTranslations['enter_phone']
                : null,
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
                  label: Text(
                    sport.name,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).textTheme.titleLarge?.color,
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
            for (var doc in snapshot.data!.docs) {
              var data = doc.data() as Map<String, dynamic>;
              List<dynamic> trainerSportsData = data['sports'] ?? [];
              List<String> trainerSports = trainerSportsData.map((sport) {
                if (sport is Map<String, dynamic>) {
                  return sport['id'] as String;
                }
                return '';
              }).toList();

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
              }
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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar(Localization.membershipTranslations['fill_required']!, Colors.red);
      return;
    }

    if (_selectedSports.isEmpty) {
      _showSnackBar(Localization.membershipTranslations['select_sport']!, Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Calculate the total paid based on selected sports asynchronously
      double totalPaid = await _calculateTotalPaid(_selectedSports);

      // Create the Member object
      final member = Member(
        id: widget.member?.id ?? '',
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        phoneNumber: _phoneController.text,
        createdAt: widget.member?.createdAt ?? DateTime.now(),
        membershipExpiration: _membershipExpiration,
        totalPaid: totalPaid,
        paymentDates: widget.member?.paymentDates ?? [],
        sports: _selectedSports,
        clientIds: _selectedMemberType == "trainer" ? [] : widget.member?.clientIds ?? null,
        notes: _notesController.text,
        memberType: _selectedMemberType,
      );

      WriteBatch batch = FirebaseFirestore.instance.batch();
      late DocumentReference memberRef;

      if (widget.member == null) {
        // Add a new client/member using batched write
        memberRef = FirebaseFirestore.instance.collection('clients').doc();
        batch.set(memberRef, member.toMap());

        // Add to trainer if selected
        if (_selectedTrainerId != null) {
          batch.update(
            FirebaseFirestore.instance.collection('trainers').doc(_selectedTrainerId),
            {'clientIds': FieldValue.arrayUnion([memberRef.id])},
          );
          // Call the _addClientToTrainer function after the batch update
          await _addClientToTrainer(memberRef.id, _selectedTrainerId!);
        }
      } else {
        // Edit existing member using batched write
        if(member.memberType == "client") {
          memberRef = FirebaseFirestore.instance.collection('clients').doc(widget.member!.id);
        } else {
          memberRef = FirebaseFirestore.instance.collection('trainers').doc(widget.member!.id);
        }

        // Check if the document exists before updating
        DocumentSnapshot memberDoc = await memberRef.get();
        if (!memberDoc.exists) {
          _showSnackBar('Member document not found.', Colors.red);
          print('Member document not found for ID: ${widget.member!.id}');
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

      _showSnackBar(Localization.membershipTranslations['success']!, Colors.green);
      Navigator.pop(context, updatedMember); // Return the updated Member object
    } catch (e) {
      _showSnackBar('${Localization.membershipTranslations['error']}: $e', Colors.red);
      print('Error occurred: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white),
            const SizedBox(width: 8),
            Flexible( // Use Flexible here
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis, // Optional: Adds ellipsis for overflow
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
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
