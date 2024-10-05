import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?) validator;
  final int maxLines; // New maxLines parameter with default value

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
    this.maxLines = 1, // Default to 1 if not provided
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines, // Set maxLines here
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).iconTheme.color),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[850]
            : Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        labelStyle: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        errorStyle: const TextStyle(
          fontFamily: 'Cairo', // Use Cairo font for error messages
          color: Colors.red, // You can change the error message color if needed
          fontSize: 14, // Adjust font size for error message
        ),
      ),
      validator: validator,
    );
  }
}
