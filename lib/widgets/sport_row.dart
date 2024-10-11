import 'package:flutter/material.dart';

class SportRow extends StatelessWidget {
  final String sportName;
  final int memberCount;
  final int totalMembers;

  const SportRow({
    Key? key,
    required this.sportName,
    required this.memberCount,
    required this.totalMembers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percentage = (memberCount / totalMembers * 100).toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8), // Increased vertical padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                sportName,
                style: const TextStyle(
                  fontSize: 16, // Increased font size for sport name
                  fontFamily: 'Cairo', // Use Cairo font
                ),
              ),
              Text(
                '$memberCount ($percentage%)',
                style: const TextStyle(
                  fontSize: 16, // Increased font size for member count
                  fontFamily: 'Cairo', // Use Cairo font
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: totalMembers > 0 ? memberCount / totalMembers : 0, // Handle division by zero
            backgroundColor: Colors.grey[200],
            color: Theme.of(context).primaryColor, // Change progress color
          ),
        ],
      ),
    );
  }
}
