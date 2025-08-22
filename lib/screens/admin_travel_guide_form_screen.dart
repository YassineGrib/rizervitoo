import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import '../constants/app_styles.dart';
import '../models/travel_guide.dart';

class AdminTravelGuideFormScreen extends StatefulWidget {
  final TravelGuide? guide;
  
  const AdminTravelGuideFormScreen({super.key, this.guide});

  @override
  State<AdminTravelGuideFormScreen> createState() => _AdminTravelGuideFormScreenState();
}

class _AdminTravelGuideFormScreenState extends State<AdminTravelGuideFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  String _selectedCategory = 'cultural';
  bool _isPublished = false;
  bool _isLoading = false;
  
  final List<String> _categories = [
    'historical',
    'natural',
    'cultural',
    'adventure',
    'religious',
    'beach',
    'mountain',
  ];
  
  final Map<String, String> _categoryLabels = {
    'historical': 'تاريخي',
    'natural': 'طبيعي',
    'cultural': 'ثقافي',
    'adventure': 'مغامرة',
    'religious': 'ديني',
    'beach': 'شاطئ',
    'mountain': 'جبلي',
  };
  


  @override
  void initState() {
    super.initState();
    if (widget.guide != null) {
      _populateForm();
    }
  }

  void _populateForm() {
    final guide = widget.guide!;
    _titleController.text = guide.title;
    _descriptionController.text = guide.description;
    _cityController.text = guide.location;
    _latitudeController.text = guide.latitude?.toString() ?? '';
    _longitudeController.text = guide.longitude?.toString() ?? '';
    _selectedCategory = guide.category;
    _isPublished = guide.isPublished;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();

    super.dispose();
  }

  Future<void> _saveGuide() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final guideData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'content': _descriptionController.text.trim(), // Using description as content for now
        'location': _cityController.text.trim(),
        'tags': [], // Empty tags array for now
        'view_count': 0, // Initialize view count to 0
        'latitude': _latitudeController.text.isNotEmpty 
            ? double.tryParse(_latitudeController.text) 
            : null,
        'longitude': _longitudeController.text.isNotEmpty 
            ? double.tryParse(_longitudeController.text) 
            : null,
        'category': _selectedCategory,
        'is_published': _isPublished,
      };

      if (widget.guide != null) {
        // Update existing guide
        await AdminService.updateTravelGuide(widget.guide!.id, guideData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'تم تحديث الدليل السياحي بنجاح',
                style: TextStyle(fontFamily: 'Tajawal'),
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Create new guide
        await AdminService.createTravelGuide(guideData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'تم إنشاء الدليل السياحي بنجاح',
                style: TextStyle(fontFamily: 'Tajawal'),
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'فشل في حفظ الدليل السياحي: ${e.toString()}',
              style: const TextStyle(fontFamily: 'Tajawal'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.guide != null ? 'تعديل الدليل السياحي' : 'إضافة دليل سياحي جديد',
          style: const TextStyle(
            fontFamily: 'Amiri',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppStyles.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveGuide,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'حفظ',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tajawal',
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information Section
              _buildSectionCard(
                'المعلومات الأساسية',
                [
                  _buildTextField(
                    controller: _titleController,
                    label: 'عنوان الدليل السياحي',
                    hint: 'أدخل عنوان الدليل السياحي',
                    required: true,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _descriptionController,
                    label: 'الوصف',
                    hint: 'أدخل وصف مفصل للمكان',
                    maxLines: 4,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Location Section
              _buildSectionCard(
                'معلومات الموقع',
                [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _cityController,
                          label: 'المدينة',
                          hint: 'أدخل اسم المدينة',
                          required: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _stateController,
                          label: 'الولاية',
                          hint: 'أدخل اسم الولاية',
                          required: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _latitudeController,
                          label: 'خط العرض',
                          hint: '36.7538',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _longitudeController,
                          label: 'خط الطول',
                          hint: '3.0588',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Category and Difficulty Section
              _buildSectionCard(
                'التصنيف والصعوبة',
                [
                  _buildDropdownField(
                    label: 'التصنيف',
                    value: _selectedCategory,
                    items: _categories.map((category) => DropdownMenuItem(
                      value: category,
                      child: Text(
                        _categoryLabels[category]!,
                        style: const TextStyle(fontFamily: 'Tajawal'),
                      ),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),

                ],
              ),
              const SizedBox(height: 16),
              

              
              // Publication Settings Section
              _buildSectionCard(
                'إعدادات النشر',
                [
                  SwitchListTile(
                    title: const Text(
                      'نشر الدليل السياحي',
                      style: TextStyle(fontFamily: 'Tajawal'),
                    ),
                    subtitle: const Text(
                      'جعل الدليل مرئياً للمستخدمين',
                      style: TextStyle(fontFamily: 'Tajawal'),
                    ),
                    value: _isPublished,
                    onChanged: (value) {
                      setState(() {
                        _isPublished = value;
                      });
                    },
                    activeThumbColor: AppStyles.primaryColor,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveGuide,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyles.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          widget.guide != null ? 'تحديث الدليل السياحي' : 'إنشاء الدليل السياحي',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Amiri',
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(fontFamily: 'Tajawal'),
        hintStyle: const TextStyle(fontFamily: 'Tajawal'),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppStyles.primaryColor),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: required
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'هذا الحقل مطلوب';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontFamily: 'Tajawal'),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppStyles.primaryColor),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: items,
      onChanged: onChanged,
    );
  }
}