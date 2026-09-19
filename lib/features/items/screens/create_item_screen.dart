import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/core.dart';
import '../data/item_api.dart';

/// Standardized CreateItemScreen conforming to Section 20 & 21 of UniTrace Master Design:
/// Rules:
/// - Clear classification toggle: [ I Lost Something ] vs [ I Found Something ]
/// - Standardized AppTextField inputs (min 48px height, persistent top labels)
/// - Photo attachment box with clean dashed/bordered style
/// - Responsive card container (max 600px)
/// - Full design token integration (context.appColors, AppTypography, AppSpacing, AppRadius)
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
  final _categoryController = TextEditingController();
  final _itemApi = ItemApi();
  final _imagePicker = ImagePicker();

  late String _type;
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;
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
    _categoryController.dispose();
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
        final bytes = await picked.readAsBytes();
        setState(() {
          _selectedImage = picked;
          _selectedImageBytes = bytes;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showImagePickerModal(AppCustomColors customColors) {
    showModalBottomSheet(
      context: context,
      backgroundColor: customColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.bottomSheet,
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Wrap(
              children: [
                ListTile(
                  leading: Icon(Icons.camera_alt_outlined, color: customColors.primary),
                  title: Text(
                    'Take Photo with Camera',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      color: customColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_library_outlined, color: customColors.primary),
                  title: Text(
                    'Choose from Gallery',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      color: customColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
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
        category: _categoryController.text.trim().isNotEmpty
            ? _categoryController.text.trim()
            : null,
        imageFile: _selectedImage,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$_type item report created successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit item: ${e.toString().split('\n').first}'),
          backgroundColor: AppColors.error,
        ),
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

    final isLost = _type == 'LOST';

    return Scaffold(
      backgroundColor: customColors.background,
      appBar: AppBar(
        title: Text(
          'File ${isLost ? 'Lost Item' : 'Found Item'} Report',
          style: AppTypography.cardTitle.copyWith(fontSize: 18),
        ),
        backgroundColor: customColors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Item Classification Toggle Cards
                    Text(
                      'Report Classification',
                      style: AppTypography.label.copyWith(color: customColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Expanded(
                          child: _buildClassificationCard(
                            title: 'I Lost It',
                            subtitle: 'Search & request help',
                            icon: Icons.search_rounded,
                            isSelected: isLost,
                            customColors: customColors,
                            onTap: () => setState(() => _type = 'LOST'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _buildClassificationCard(
                            title: 'I Found It',
                            subtitle: 'Hand in to Security',
                            icon: Icons.inventory_2_outlined,
                            isSelected: !isLost,
                            customColors: customColors,
                            onTap: () => setState(() => _type = 'FOUND'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Main Form Card
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: customColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        border: Border.all(color: customColors.border),
                        boxShadow: AppShadows.card,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Item Title
                          AppTextField(
                            label: 'Item Title *',
                            hintText: 'e.g. Silver 14" MacBook Pro, Blue Hydro Flask',
                            controller: _titleController,
                            prefixIcon: const Icon(Icons.title, size: 20),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter an item title';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Location on Campus
                          AppTextField(
                            label: 'Campus Location *',
                            hintText: 'e.g. Main Library 2nd Floor, Room 304, Cafeteria',
                            controller: _locationController,
                            prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please specify the location on campus';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Category
                          AppTextField(
                            label: 'Category (Optional)',
                            hintText: 'e.g. Electronics, Bags, Keys, IDs & Cards',
                            controller: _categoryController,
                            prefixIcon: const Icon(Icons.category_outlined, size: 20),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Description
                          AppTextField(
                            label: 'Identifying Details & Description *',
                            hintText:
                                'Specify color, brand, stickers, serials, keychains, or unique marks...',
                            controller: _descController,
                            maxLines: 4,
                            alignLabelWithHint: true,
                            prefixIcon: const Icon(Icons.notes_outlined, size: 20),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please provide distinguishing details';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // Photo Attachment Box
                          Text(
                            'Item Photo (Recommended)',
                            style: AppTypography.label.copyWith(color: customColors.textSecondary),
                          ),
                          const SizedBox(height: AppSpacing.xs),

                          if (_selectedImage != null)
                            Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Container(
                                  height: 180,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: customColors.surface,
                                    borderRadius: BorderRadius.circular(AppRadius.input),
                                    border: Border.all(color: customColors.border),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(AppRadius.input),
                                    child: _selectedImageBytes != null
                                        ? Image.memory(
                                            _selectedImageBytes!,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: 180,
                                          )
                                        : const Center(
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          ),
                                  ),
                                ),
                                IconButton(
                                  icon: CircleAvatar(
                                    backgroundColor: customColors.surface,
                                    radius: 16,
                                    child: Icon(Icons.close, size: 16, color: customColors.textPrimary),
                                  ),
                                  onPressed: () => setState(() {
                                    _selectedImage = null;
                                    _selectedImageBytes = null;
                                  }),
                                ),
                              ],
                            )
                          else
                            InkWell(
                              onTap: () => _showImagePickerModal(customColors),
                              borderRadius: BorderRadius.circular(AppRadius.input),
                              child: Container(
                                height: 110,
                                decoration: BoxDecoration(
                                  color: customColors.background,
                                  borderRadius: BorderRadius.circular(AppRadius.input),
                                  border: Border.all(
                                    color: customColors.border,
                                    width: 1.2,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo_outlined,
                                      size: 32,
                                      color: customColors.primary,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Attach photo from camera or gallery',
                                      style: AppTypography.secondary.copyWith(
                                        color: customColors.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          const SizedBox(height: AppSpacing.xl),

                          // Submit Action Button
                          AppButton(
                            text: 'Submit ${isLost ? 'Lost Item' : 'Found Item'} Report',
                            isLoading: _isSubmitting,
                            icon: Icons.send_rounded,
                            onPressed: _handleSubmit,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClassificationCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required AppCustomColors customColors,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? customColors.primaryLight : customColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: isSelected ? customColors.primary : customColors.border,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.card),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected ? customColors.primary : customColors.background,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: isSelected ? Colors.white : customColors.textSecondary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? customColors.primary : customColors.textPrimary,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: AppTypography.caption.copyWith(
                          color: isSelected ? customColors.primary : customColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
