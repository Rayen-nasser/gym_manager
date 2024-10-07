import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart'; // Import this for date initialization
import 'package:gym_energy/widgets/text_flied.dart';

import '../../localization.dart';
import '../../model/member.dart';
import '../../model/sport.dart';

class AddEditClientScreen extends StatefulWidget {
  const AddEditClientScreen({Key? key}) : super(key: key);

  @override
  State<AddEditClientScreen> createState() => _AddEditClientScreenState();
}

class _AddEditClientScreenState extends State<AddEditClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedMemberType = "trainee";
  DateTime _membershipExpiration = DateTime.now().add(const Duration(days: 30));
  String? _selectedTrainerId;
  List<Sport> _selectedSports = [];
  bool _isLoading = false;

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
              value: 'trainee', // Use string value
              label: Text(
                Localization.membershipTranslations['trainee'] ?? 'Trainee',
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
          _selectedMemberType == "trainee"
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
                var sport = Sport.fromMap(doc.data() as Map<String, dynamic>);
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
    // Validate the form first
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Localization.membershipTranslations['fill_required']!),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Ensure a sport is selected
    if (_selectedSports.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Localization.membershipTranslations['select_sport']!),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Set loading state to true
    setState(() => _isLoading = true);

    try {
      // Calculate the total paid based on selected sports
      double totalPaid = await _calculateTotalPaid(_selectedSports);

      // Create the client object
      final client = Member(
        id: '',
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        phoneNumber: _phoneController.text,
        createdAt: DateTime.now(),
        membershipExpiration: _membershipExpiration,
        totalPaid: totalPaid,
        paymentDates: [],
        sports: _selectedSports,
        clientIds: _selectedMemberType == "trainer" ? [] : null,
        notes: _notesController.text,
        memberType: _selectedMemberType,
      );

      // Add the client to Firestore
      if (_selectedMemberType == "trainer") {
        // Save client as a trainer
        await FirebaseFirestore.instance.collection('trainers').add(client.toMap());
      } else {
        // Save client as a regular client
        DocumentReference clientDocRef = await FirebaseFirestore.instance
            .collection('clients')
            .add(client.toMap());
        String newClientId = clientDocRef.id;

        // Check if a trainer is selected and the sport is NOT "كمال الاجسام" (Bodybuilding)
        if (_selectedTrainerId != null) {
          await _addClientToTrainer(newClientId, _selectedTrainerId!);
        }
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(Localization.membershipTranslations['success']!),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      // Handle error and show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text('${Localization.membershipTranslations['error']}: ${e.toString()}'),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Reset loading state
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
