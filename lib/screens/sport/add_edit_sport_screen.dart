import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_energy/provider/members_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../model/member.dart';
import '../../model/sport.dart';
import '../../widgets/text_flied.dart'; // Make sure this path is correct

class AddEditSportScreen extends StatefulWidget {
  final Sport? sport; // Optional sport object for editing

  const AddEditSportScreen({Key? key, this.sport}) : super(key: key);

  @override
  _AddEditSportScreenState createState() => _AddEditSportScreenState();
}

class _AddEditSportScreenState extends State<AddEditSportScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _durationController;
  bool _isLoading = false; // Loading state

  @override
  void initState() {
    super.initState();

    // If sport exists (editing), pre-fill the fields; otherwise, set them empty (adding)
    _nameController = TextEditingController(text: widget.sport?.name ?? '');
    _priceController = TextEditingController(text: widget.sport?.price.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.sport?.description ?? '');
    _durationController = TextEditingController(text: widget.sport?.sessionDuration.toString() ?? '60');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

// Function to save the sport
  Future<void> _saveSport() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true; // Show loading indicator
      });

      try {
        final sportData = {
          'id': widget.sport?.id ?? const Uuid().v4(), // Generate new UUID if adding a new sport
          'name': _nameController.text.trim(),
          'price': double.tryParse(_priceController.text) ?? 0,
          'description': _descriptionController.text.trim(),
          'sessionDuration': int.tryParse(_durationController.text) ?? 60,
        };

        // Check if sport with the same name already exists
        final existingSportQuery = await FirebaseFirestore.instance
            .collection('sports')
            .where('name', isEqualTo: sportData['name'])
            .limit(1)
            .get();

        final isExistingSport = existingSportQuery.docs.isNotEmpty;

        if (isExistingSport && widget.sport == null) {
          // Show error if trying to add a new sport with a duplicate name
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sport with this name already exists.')),
          );
        } else {
          if (widget.sport == null) {
            // Add new sport
            await FirebaseFirestore.instance.collection('sports').doc(sportData['id'] as String).set(sportData);
          } else {
            // Update existing sport by ID using update method
            await FirebaseFirestore.instance
                .collection('sports')
                .doc(widget.sport!.id)
                .update(sportData);
          }

          // Create Sport object to return
          final savedSport = Sport(
            id: sportData['id'] as String,
            name: sportData['name'] as String,
            price: (sportData['price'] as num).toDouble(),
            description: sportData['description'] as String,
            sessionDuration: sportData['sessionDuration'] as int,
          );

          // Now update the price for all members who have this sport enrolled
          if(savedSport.price != widget.sport?.price){
            // Use the existing instance of MembersProvider to update sport prices
            final membersProvider = Provider.of<MembersProvider>(context, listen: false);
            await membersProvider.updateMemberSportPrices(savedSport);
          }

          Navigator.of(context).pop(savedSport);
        }
      } catch (e) {
        print('Error saving sport: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save sport. Please try again.')),
        );
      } finally {
        setState(() {
          _isLoading = false; // Hide loading indicator
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.sport == null ? 'إضافة رياضة' : 'تعديل الرياضة', // Dynamic title
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CustomTextField(
                controller: _nameController,
                label: 'اسم الرياضة',
                icon: Icons.sports,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال اسم الرياضة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _priceController,
                label: 'سعر الجلسة',
                icon: Icons.attach_money,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال سعر الجلسة';
                  }
                  if (double.tryParse(value) == null) {
                    return 'يرجى إدخال رقم صحيح';
                  }
                  return null;
                },
                maxLines: 1,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _descriptionController,
                label: 'وصف الرياضة',
                icon: Icons.description,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال وصف الرياضة';
                  }
                  return null;
                },
                maxLines: 3, // Multi-line for the description
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _durationController,
                label: 'مدة الجلسة بالدقائق',
                icon: Icons.timer,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال مدة الجلسة';
                  }
                  if (int.tryParse(value) == null) {
                    return 'يرجى إدخال رقم صحيح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveSport,
                child: Text(
                  widget.sport == null ? 'إضافة رياضة' : 'تحديث الرياضة',
                  style: const TextStyle(fontSize: 18, fontFamily: 'Cairo'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
