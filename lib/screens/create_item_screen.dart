import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../api/item_api.dart';
import '../theme/app_theme.dart';
import '../widgets/app_button.dart';

class CreateItemScreen extends StatefulWidget {
  final String initialType;

  const CreateItemScreen({super.key, this.initialType = 'LOST'});

  @override
  State<CreateItemScreen> createState() => _CreateItemScreenState();
}

class _CreateItemScreenState extends State<CreateItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  final _itemApi = ItemApi();
  final _imagePicker = ImagePicker();

  late String _type;
  File? _selectedImage;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _selectedImage = File(picked.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  void _showImagePickerModal(AppCustomColors customColors) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt_outlined, color: customColors.navyPrimary),
                title: Text(
                  'Take Photo with Camera',
                  style: TextStyle(color: customColors.textPrimary, fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library_outlined, color: customColors.navyPrimary),
                title: Text(
                  'Choose from Gallery',
                  style: TextStyle(color: customColors.textPrimary, fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await _itemApi.createItem(
        type: _type,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        location: _locationController.text.trim(),
        imageFile: _selectedImage,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$_type item reported successfully!')),
      );
      Navigator.pop(context, true); // Pop and signal refresh
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit item: ${e.toString().split('\n').first}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final customColors = context.appColors;
    final colorScheme = Theme.of(context).colorScheme;

    final lostSelected = _type == 'LOST';
    final foundSelected = _type == 'FOUND';

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Report ${_type == 'LOST' ? 'Lost' : 'Found'} Item',
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Radio/Toggle: LOST or FOUND
                Text(
                  'Item Classification',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: customColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text(
                          'I Lost It',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: lostSelected ? customColors.typeLost.text : customColors.textPrimary,
                          ),
                        ),
                        value: 'LOST',
                        groupValue: _type,
                        activeColor: customColors.typeLost.text,
                        tileColor: colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: lostSelected ? customColors.typeLost.text : customColors.borderDivider,
                            width: lostSelected ? 1.5 : 1,
                          ),
                        ),
                        onChanged: (val) {
                          if (val != null) setState(() => _type = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text(
                          'I Found It',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: foundSelected ? customColors.typeFound.text : customColors.textPrimary,
                          ),
                        ),
                        value: 'FOUND',
                        groupValue: _type,
                        activeColor: customColors.typeFound.text,
                        tileColor: colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: foundSelected ? customColors.typeFound.text : customColors.borderDivider,
                            width: foundSelected ? 1.5 : 1,
                          ),
                        ),
                        onChanged: (val) {
                          if (val != null) setState(() => _type = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Title
                TextFormField(
                  controller: _titleController,
                  style: TextStyle(color: customColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Item Title',
                    labelStyle: TextStyle(color: customColors.textMuted),
                    hintText: 'e.g. Blue Hydro Flask, Silver MacBook Air',
                    hintStyle: TextStyle(color: customColors.textMuted),
                    prefixIcon: Icon(Icons.title, color: customColors.textMuted),
                    filled: true,
                    fillColor: colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: customColors.borderDivider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: customColors.borderDivider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: customColors.navyPrimary, width: 1.5),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Location
                TextFormField(
                  controller: _locationController,
                  style: TextStyle(color: customColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Location on Campus',
                    labelStyle: TextStyle(color: customColors.textMuted),
                    hintText: 'e.g. Library 2nd Floor, Room 304, Cafeteria',
                    hintStyle: TextStyle(color: customColors.textMuted),
                    prefixIcon: Icon(Icons.location_on_outlined, color: customColors.textMuted),
                    filled: true,
                    fillColor: colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: customColors.borderDivider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: customColors.borderDivider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: customColors.navyPrimary, width: 1.5),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please specify the campus location';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Description
                TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  style: TextStyle(color: customColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Description & Identifying Marks',
                    labelStyle: TextStyle(color: customColors.textMuted),
                    hintText: 'Provide color, brand, stickers, keychains or specific details...',
                    hintStyle: TextStyle(color: customColors.textMuted),
                    alignLabelWithHint: true,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: Icon(Icons.notes_outlined, color: customColors.textMuted),
                    ),
                    filled: true,
                    fillColor: colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: customColors.borderDivider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: customColors.borderDivider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: customColors.navyPrimary, width: 1.5),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please provide a brief description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Image Picker & Preview
                Text(
                  'Item Photo (Recommended)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: customColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),

                if (_selectedImage != null)
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: customColors.borderDivider),
                          image: DecorationImage(
                            image: FileImage(_selectedImage!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: CircleAvatar(
                          backgroundColor: customColors.surfaceLight,
                          radius: 16,
                          child: Icon(Icons.close, size: 18, color: customColors.textPrimary),
                        ),
                        onPressed: () => setState(() => _selectedImage = null),
                      ),
                    ],
                  )
                else
                  InkWell(
                    onTap: () => _showImagePickerModal(customColors),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: customColors.borderDivider,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined, size: 36, color: customColors.textMuted),
                          const SizedBox(height: 8),
                          Text(
                            'Attach Camera or Gallery Photo',
                            style: TextStyle(
                              color: customColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 28),

                // Submit Button
                AppButton(
                  text: 'Submit $_type Report',
                  isLoading: _isSubmitting,
                  icon: Icons.send_rounded,
                  onPressed: _handleSubmit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
