import 'package:flutter/material.dart';

// Enum to define the different membership types
enum MemberType { personal, trainer }

class TypeSelectionWidget extends StatefulWidget {
  final Map<String, String> translations;
  final MemberType initialMemberType;

  const TypeSelectionWidget({
    Key? key,
    required this.translations,
    required this.initialMemberType,
  }) : super(key: key);

  @override
  _TypeSelectionWidgetState createState() => _TypeSelectionWidgetState();
}

class _TypeSelectionWidgetState extends State<TypeSelectionWidget> {
  late MemberType _selectedMemberType;

  @override
  void initState() {
    super.initState();
    _selectedMemberType = widget.initialMemberType;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title for the membership type selection
        Text(
          widget.translations['membership_type'] ?? 'Membership Type',
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
                widget.translations['client'] ?? 'Client',
                style: TextStyle(
                  fontFamily: 'Cairo', // Using Cairo font
                  fontWeight: FontWeight.w400, // Normal weight
                  fontSize: 16, // Adjust font size
                  color: Theme.of(context).textTheme.bodyLarge?.color, // Theme-based color
                ),
              ),
              icon: const Icon(Icons.person),
            ),
            ButtonSegment(
              value: MemberType.trainer,
              label: Text(
                widget.translations['trainer'] ?? 'Trainer',
                style: TextStyle(
                  fontFamily: 'Cairo', // Using Cairo font
                  fontWeight: FontWeight.w600, // Bold weight
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyLarge?.color, // Theme-based color
                ),
              ),
              icon: const Icon(Icons.fitness_center),
            ),
          ],
          selected: {_selectedMemberType},
          onSelectionChanged: (Set<MemberType> selection) {
            setState(() {
              _selectedMemberType = selection.first;
              // Additional logic for trainer selection
              if (_selectedMemberType == MemberType.trainer) {
                // Perform any specific action when trainer is selected
              }
            });
          },
          style: ButtonStyle(
            // Button background color based on the selected state
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                if (states.contains(MaterialState.selected)) {
                  return Theme.of(context).primaryColor; // Gym theme primary color
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
}
