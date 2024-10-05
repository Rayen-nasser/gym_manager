import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart'; // Import this for date initialization
import 'package:gym_energy/widgets/text_flied.dart';

import '../../localization.dart';
import '../../model/client.dart';
import '../../model/sport.dart';

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

  MemberType _selectedMemberType = MemberType.personal;
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
                    if (isTablet) _buildTabletLayout(constraints) else _buildPhoneLayout(),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // // Section title: Personal Information
                  // Text(
                  //   Localization.membershipTranslations['personal_info'] ?? 'Personal Information',
                  //   style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  //     fontWeight: FontWeight.bold,
                  //     color: Theme.of(context).colorScheme.primary,
                  //   ),
                  // ),
                  // const SizedBox(height: 24),

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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section title: Subscription Details
                  // Text(
                  //   Localization.membershipTranslations['subscription_details'] ?? 'Subscription Details',
                  //   style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  //     fontWeight: FontWeight.bold,
                  //     color: Theme.of(context).colorScheme.primary,
                  //   ),
                  // ),
                  // const SizedBox(height: 16),

                  // Sports selection
                  _buildSportsSelection(),

                  // Conditional rendering based on member type
                  if (_selectedMemberType == MemberType.personal) ...[
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
    return Column(
      children: [
        _buildTypeSelection(context),
        const SizedBox(height: 16),
        _buildPersonalInfo(),
        const SizedBox(height: 16),
        _buildSportsSelection(),
        if (_selectedMemberType == MemberType.personal) ...[
          const SizedBox(height: 16),
          _buildTrainerSelection(),
        ],
        const SizedBox(height: 16),
        _buildNotes(),
      ],
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
        SegmentedButton<MemberType>(
          segments: [
            ButtonSegment(
              value: MemberType.personal,
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
              value: MemberType.trainer,
              label: Text(
                Localization.membershipTranslations['trainer'] ?? 'Trainer',
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
    return  Padding(
        padding: const EdgeInsets.symmetric( vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Localization.membershipTranslations['personal_info']!,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color, // Theme-based text color
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _firstNameController,
              label: Localization.membershipTranslations['first_name']!,
              icon: Icons.person_outline,
              validator: (value) => value?.isEmpty ?? true ? Localization.membershipTranslations['enter_first_name'] : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _lastNameController,
              label: Localization.membershipTranslations['last_name']!,
              icon: Icons.person_outline,
              validator: (value) => value?.isEmpty ?? true ? Localization.membershipTranslations['enter_last_name'] : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _emailController,
              label: Localization.membershipTranslations['email']!,
              icon: Icons.email_outlined,
              validator: (value) {
                if (value?.isEmpty ?? true) return Localization.membershipTranslations['enter_email'];
                if (!value!.contains('@')) return Localization.membershipTranslations['enter_valid_email'];
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _phoneController,
              label: Localization.membershipTranslations['phone']!,
              icon: Icons.phone_outlined,
              validator: (value) => value?.isEmpty ?? true ? Localization.membershipTranslations['enter_phone'] : null,
            ),
          ],
        ),
    );
  }

  Widget _buildTrainerSelection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
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
            stream: FirebaseFirestore.instance
                .collection('trainers')
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

                // Check if the trainer can teach any of the selected sports
                List<dynamic> trainerSportsData = data['sports'] ?? []; // Adjusted to dynamic
                List<String> trainerSports = trainerSportsData.map((sport) {
                  // Assuming each sport is a map and you want to get the 'id'
                  if (sport is Map<String, dynamic>) {
                    return sport['id'] as String; // Ensure this returns a string ID
                  }
                  return ''; // Fallback if not a map
                }).toList();

                // Check if the trainer can teach any of the selected sports
                bool canTeach = _selectedSports.any((sport) => trainerSports.contains(sport.id));

                if (canTeach) {
                  trainerItems.add(DropdownMenuItem(
                    value: doc.id,
                    child: Text(
                      '${data['firstName']} ${data['lastName']}',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
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
                  prefixIcon: Icon(Icons.fitness_center, color: Theme.of(context).iconTheme.color),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[850]
                      : Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                  ),
                  errorStyle: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                value: _selectedTrainerId,
                items: trainerItems.isNotEmpty ? trainerItems : null,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedTrainerId = newValue;
                  });
                },
                validator: (value) =>
                value == null ? Localization.membershipTranslations['choose_trainer'] : null,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSportsSelection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedMemberType == MemberType.trainer
                ? Localization.membershipTranslations['sports_to_teach']!
                : Localization.membershipTranslations['sports_to_join']!,
            style: TextStyle(
              fontSize: 20, // Slightly larger for emphasis
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color, // Using primary color for gym theme
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
                    spacing: 10, // Increased spacing for better readability
                    runSpacing: 10,
                    children: snapshot.data!.docs.map((doc) {
                      var sport = Sport.fromMap(doc.data() as Map<String, dynamic>);
                      bool isSelected = _selectedSports.any((s) => s.id == sport.id);

                      return ChoiceChip(
                        label: Text(
                          sport.name,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color, // Text color based on selection
                            fontWeight: FontWeight.bold,
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
                            ? Colors.grey[800] // Dark mode background color for unselected chips
                            : Colors.grey[200], // Light mode background color for unselected chips
                        selectedColor: Theme.of(context).colorScheme.primary, // Primary color for selection
                        elevation: 4, // Add elevation for shadow effect
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // Rounded corners
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
                Localization.membershipTranslations['select_sport']!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error, // Use theme error color
                  fontSize: 14, // Slightly larger for better visibility
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotes() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Localization.membershipTranslations['additional_notes']!,
            style: TextStyle(
              fontSize: 20, // Slightly larger for better emphasis
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,  // Using primary color for theme
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _notesController,
            decoration: InputDecoration(
              labelText: Localization.membershipTranslations['notes'],
              labelStyle: TextStyle(
                color: Theme.of(context).colorScheme.onBackground, // Using theme's secondary color for label
              ),
              prefixIcon: Icon(Icons.note_outlined, color: Theme.of(context).iconTheme.color), // Theme-based icon color
              hintText: Localization.membershipTranslations['add_notes'],
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), // Faded hint text
              ),
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[850] // Dark mode fill color
                  : Colors.grey[200], // Light mode fill color
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12), // Rounded corners
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), // Subtle border color
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary, // Primary color on focus
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), // Subtle border color
                ),
              ),
            ),
            maxLines: 3,
            textAlign: TextAlign.start, // Align text to start for better readability
            style: TextStyle(
              fontFamily: 'Cairo', // Use Cairo font family
              fontSize: 16, // Consistent font size for text input
              color: Theme.of(context).textTheme.bodyLarge?.color, // Text color from theme
            ),
          ),
        ],
      ),
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
      icon: _isLoading
          ? CircularProgressIndicator(
        color: Colors.white,
        strokeWidth: 2,
      )
          : const Icon(Icons.add, color: Colors.white),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Localization.membershipTranslations['fill_required']!),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedSports.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Localization.membershipTranslations['select_sport']!),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      double totalPaid = await _calculateTotalPaid(_selectedSports);
      final client = Client(
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
        assignedTrainerId: _selectedMemberType == MemberType.personal ? _selectedTrainerId : null,
        clientIds: _selectedMemberType == MemberType.trainer ? [] : null,
        notes: _notesController.text,
      );

      if (_selectedMemberType == MemberType.trainer) {
        await FirebaseFirestore.instance.collection('trainers').add(client.toMap());
      } else {
        DocumentReference clientDocRef = await FirebaseFirestore.instance.collection('clients').add(client.toMap());
        String newClientId = clientDocRef.id;
        await _addClientToTrainer(newClientId, _selectedTrainerId!);
      }

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
      setState(() => _isLoading = false); // Ensure loading state resets
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
    await FirebaseFirestore.instance.collection('trainers').doc(trainerId).update({
      'clientIds': FieldValue.arrayUnion([clientId]), // Add client ID to the list
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
