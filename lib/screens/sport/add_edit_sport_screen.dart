import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this for Firebase
import 'package:flutter/services.dart';

import '../../model/sport.dart';

class AddEditSportScreen extends StatefulWidget {
  final Sport? sport; // Pass null for adding a new sport

  const AddEditSportScreen({Key? key, this.sport}) : super(key: key);

  @override
  _AddEditSportScreenState createState() => _AddEditSportScreenState();
}

class _AddEditSportScreenState extends State<AddEditSportScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form field controllers
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _sessionDurationController;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with the passed sport object if available
    _nameController = TextEditingController(text: widget.sport?.name ?? '');
    _priceController = TextEditingController(
        text: widget.sport?.price.toStringAsFixed(2) ?? '');
    _descriptionController =
        TextEditingController(text: widget.sport?.description ?? '');
    _sessionDurationController = TextEditingController(
        text: widget.sport?.sessionDuration.toString() ?? '60');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _sessionDurationController.dispose();
    super.dispose();
  }

  // Function to save to Firebase
  Future<void> _saveToFirebase(Sport newSport) async {
    final CollectionReference sportsCollection =
    FirebaseFirestore.instance.collection('sports');

    if (widget.sport == null) {
      // Add new sport
      await sportsCollection.add(newSport.toMap());
    } else {
      // Update existing sport
      await sportsCollection.doc(widget.sport!.id).update(newSport.toMap());
    }
  }

  // Save the form
  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final newSport = Sport(
        id: widget.sport?.id ?? DateTime.now().toString(),
        name: _nameController.text,
        price: double.parse(_priceController.text),
        description: _descriptionController.text,
        sessionDuration: int.parse(_sessionDurationController.text),
      );
      _saveToFirebase(newSport).then((_) {
        Navigator.pop(context, newSport); // Return the new/edited sport
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء حفظ الرياضة')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.sport == null ? 'إضافة رياضة' : 'تعديل رياضة'),
          actions: [
            IconButton(
              icon: Icon(Icons.save),
              onPressed: _saveForm,
            ),
          ],
        ),
        body: Padding(
        padding: const EdgeInsets.all(16.0),
    child: Form(
    key: _formKey,
    child: ListView(
    children: [
    TextFormField(
    controller: _nameController,
    decoration: InputDecoration(
    labelText: 'اسم الرياضة',
    hintText: 'أدخل اسم الرياضة',
    border: OutlineInputBorder(),
    ),
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'الرجاء إدخال اسم الرياضة';
    }
    return null;
    },
      textDirection: TextDirection.rtl, // Aligns text for Arabic content
      textAlign: TextAlign.right, // Aligns input to the right
    ),
      SizedBox(height: 16),
      TextFormField(
        controller: _priceController,
        decoration: InputDecoration(
          labelText: 'السعر',
          hintText: 'أدخل السعر',
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'الرجاء إدخال السعر';
          }
          if (double.tryParse(value) == null) {
            return 'الرجاء إدخال قيمة صحيحة';
          }
          return null;
        },
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
      ),
      SizedBox(height: 16),
      TextFormField(
        controller: _descriptionController,
        decoration: InputDecoration(
          labelText: 'الوصف',
          hintText: 'أدخل وصف الرياضة',
          border: OutlineInputBorder(),
        ),
        maxLines: 3,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
      ),
      SizedBox(height: 16),
      TextFormField(
        controller: _sessionDurationController,
        decoration: InputDecoration(
          labelText: 'مدة الجلسة (بالدقائق)',
          hintText: 'أدخل مدة الجلسة',
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'الرجاء إدخال مدة الجلسة';
          }
          if (int.tryParse(value) == null) {
            return 'الرجاء إدخال رقم صحيح';
          }
          return null;
        },
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
      ),
      SizedBox(height: 24),
      // Save and Cancel Buttons
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            onPressed: _saveForm,
            icon: Icon(Icons.save),
            label: Text('حفظ'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              backgroundColor: Theme.of(context).primaryColor,
            ),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context); // Cancel and return
            },
            icon: Icon(Icons.cancel),
            label: Text('إلغاء'),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
          ),
        ],
      ),
    ],
    ),
    ),
        ),
    );
  }
}

