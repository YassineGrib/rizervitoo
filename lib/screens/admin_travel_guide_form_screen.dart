import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/admin_service.dart';
import '../services/image_picker_service.dart';
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
  final _countryController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _bestSeasonController = TextEditingController();
  final _estimatedDurationController = TextEditingController();
  final _entryFeeController = TextEditingController();
  final _currencyController = TextEditingController();
  final _transportationInfoController = TextEditingController();
  final _highlightsController = TextEditingController();
  final _tipsController = TextEditingController();
  
  String _selectedCategory = 'cultural';
  String _selectedDifficultyLevel = 'easy';
  bool _isPublished = false;
  bool _isFeatured = false;
  bool _isLoading = false;
  
  List<File> _selectedImages = [];
  List<String> _existingImageUrls = [];
  final ImagePickerService _imagePickerService = ImagePickerService();
  
  final List<String> _categories = [
    'historical',
    'natural',
    'cultural',
    'adventure',
    'religious',
    'beach',
    'mountain',
  ];
  
  final List<String> _difficultyLevels = [
    'easy',
    'moderate',
    'difficult',
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
  
  final Map<String, String> _difficultyLabels = {
    'easy': 'سهل',
    'moderate': 'متوسط',
    'difficult': 'صعب',
  };
  


  @override
  void initState() {
    super.initState();
    // Set default values
    _countryController.text = 'الجزائر';
    _currencyController.text = 'DZD';
    
    if (widget.guide != null) {
      _populateForm();
    }
  }

  void _populateForm() {
    final guide = widget.guide!;
    _titleController.text = guide.title;
    _descriptionController.text = guide.description;
    _cityController.text = guide.city;
    _stateController.text = guide.state;
    _countryController.text = guide.country;
    _latitudeController.text = guide.latitude?.toString() ?? '';
    _longitudeController.text = guide.longitude?.toString() ?? '';
    _bestSeasonController.text = guide.bestSeason ?? '';
    _estimatedDurationController.text = guide.estimatedDuration ?? '';
    _entryFeeController.text = guide.entryFee.toString();
    _currencyController.text = guide.currency;
    _transportationInfoController.text = guide.transportationInfo ?? '';
    _highlightsController.text = guide.highlights.join('\n');
    _tipsController.text = guide.tips.join('\n');
    _selectedCategory = guide.category;
    _selectedDifficultyLevel = guide.difficultyLevel;
    _isPublished = guide.isPublished;
    _isFeatured = guide.isFeatured;
    _existingImageUrls = List.from(guide.images);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _bestSeasonController.dispose();
    _estimatedDurationController.dispose();
    _entryFeeController.dispose();
    _currencyController.dispose();
    _transportationInfoController.dispose();
    _highlightsController.dispose();
    _tipsController.dispose();
    super.dispose();
  }

  Future<List<String>> _uploadImages() async {
    if (_selectedImages.isEmpty) return [];
    
    List<String> uploadedUrls = [];
    
    // Try to ensure the bucket exists before uploading
    try {
      await _ensureBucketExists();
    } catch (e) {
      // Log the bucket setup issue but continue with upload attempt
      print('Bucket setup completed with warnings: $e');
      // Don't stop the upload process - the bucket might actually exist
    }
    
    for (int i = 0; i < _selectedImages.length; i++) {
      final File image = _selectedImages[i];
      try {
        final bytes = await image.readAsBytes();
        final fileName = 'travel_guide_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        
        // Upload the image
        await Supabase.instance.client.storage
            .from('travel_guides')
            .uploadBinary(fileName, bytes);
        
        // Get the public URL
        final url = Supabase.instance.client.storage
            .from('travel_guides')
            .getPublicUrl(fileName);
        
        uploadedUrls.add(url);
        print('Successfully uploaded image ${i + 1}/${_selectedImages.length}: $fileName');
      } catch (e) {
        final errorMsg = e.toString();
        print('Error uploading image ${i + 1}: $errorMsg');
        
        // Provide user-friendly error messages
        String userMessage;
        if (errorMsg.contains('Bucket not found')) {
          userMessage = 'خطأ: bucket "travel_guides" غير موجود في Supabase Storage';
        } else if (errorMsg.contains('permission') || errorMsg.contains('unauthorized')) {
          userMessage = 'خطأ: لا توجد صلاحية لرفع الصور';
        } else if (errorMsg.contains('size') || errorMsg.contains('limit')) {
          userMessage = 'خطأ: حجم الصورة كبير جداً';
        } else {
          userMessage = 'فشل في رفع الصورة ${i + 1}: $errorMsg';
        }
        
        // Show error to user but continue with other images
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                userMessage,
                style: const TextStyle(fontFamily: 'Tajawal'),
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
    
    final successCount = uploadedUrls.length;
    final totalCount = _selectedImages.length;
    
    if (successCount > 0 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم رفع $successCount من $totalCount صورة بنجاح',
            style: const TextStyle(fontFamily: 'Tajawal'),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
    
    print('Upload complete. Successfully uploaded $successCount out of $totalCount images');
    return uploadedUrls;
  }

  // Test method to verify Supabase storage connection
  Future<void> _testStorageConnection() async {
    try {
      // Test 1: List all buckets
      final buckets = await Supabase.instance.client.storage.listBuckets();
      print('Available buckets: ${buckets.map((b) => b.id).toList()}');
      
      // Test 2: Check if travel_guides bucket exists
      final travelGuidesBucket = buckets.firstWhere(
        (bucket) => bucket.id == 'travel_guides',
        orElse: () => throw Exception('travel_guides bucket not found'),
      );
      print('Found travel_guides bucket: ${travelGuidesBucket.id}');
      
      // Test 3: Try to list files in the bucket
      final files = await Supabase.instance.client.storage.from('travel_guides').list();
      print('Files in travel_guides bucket: ${files.length} files');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '✓ اتصال التخزين يعمل بنجاح',
              style: TextStyle(fontFamily: 'Tajawal'),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Storage connection test failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'خطأ في اتصال التخزين: ${e.toString()}',
              style: const TextStyle(fontFamily: 'Tajawal'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _ensureBucketExists() async {
    const bucketName = 'travel_guides';
    
    try {
      // Method 1: Try to list files in the bucket to check if it exists and is accessible
      await Supabase.instance.client.storage.from(bucketName).list();
      print('Bucket $bucketName exists and is accessible');
      return; // Bucket exists and is accessible
    } catch (listError) {
      print('Could not list files in bucket $bucketName: $listError');
      
      // Method 2: Try listing all buckets to check if it exists
      try {
        final buckets = await Supabase.instance.client.storage.listBuckets();
        final bucketExists = buckets.any((bucket) => bucket.id == bucketName);
        
        if (bucketExists) {
          print('Bucket $bucketName exists but may have access restrictions');
          return; // Bucket exists, continue with upload (RLS might block listing)
        }
        
        print('Bucket $bucketName not found in bucket list');
      } catch (bucketsError) {
        print('Could not list buckets: $bucketsError');
      }
      
      // Method 3: Try to create the bucket if it doesn't exist
      try {
        await Supabase.instance.client.storage.createBucket(
          bucketName,
          BucketOptions(
            public: true,
            allowedMimeTypes: ['image/jpeg', 'image/png', 'image/webp', 'image/jpg'],
          ),
        );
        print('Successfully created bucket $bucketName');
        return;
      } catch (createError) {
        final errorStr = createError.toString().toLowerCase();
        
        // Check if the error indicates the bucket already exists
        if (errorStr.contains('already exists') || 
            errorStr.contains('23505') ||
            errorStr.contains('duplicate key') ||
            errorStr.contains('buckets_pkey')) {
          print('Bucket $bucketName already exists (detected during creation attempt)');
          return; // Bucket exists, continue
        }
        
        // Check for permission errors - bucket exists but we can't create due to permissions
        if (errorStr.contains('permission') ||
            errorStr.contains('access') ||
            errorStr.contains('unauthorized') ||
            errorStr.contains('forbidden')) {
          print('Bucket operations restricted, but bucket likely exists. Continuing with upload attempt.');
          return; // Assume bucket exists, let upload handle any remaining errors
        }
        
        print('Bucket creation failed with unexpected error: $createError');
        
        // Only show error to user for genuine bucket setup failures
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'تحذير: قد تواجه مشاكل في رفع الصور\n'
                'تأكد من إعداد bucket "travel_guides" في Supabase Dashboard',
                style: TextStyle(fontFamily: 'Tajawal'),
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'متابعة',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        }
        
        // Don't throw error - let the upload process handle bucket issues
        print('Continuing with upload despite bucket verification issues');
      }
    }
  }

  Future<void> _pickImages() async {
    try {
      final images = await _imagePickerService.pickMultipleImages();
      setState(() {
        _selectedImages.addAll(images);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في اختيار الصور: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }
  Future<void> _saveGuide() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload images first
      final imageUrls = await _uploadImages();
      
      // Combine existing images with new ones
      final allImageUrls = [..._existingImageUrls, ...imageUrls];
      
      // Parse highlights and tips from text fields
      final highlights = _highlightsController.text.trim().isEmpty 
          ? [] 
          : _highlightsController.text.split('\n').where((h) => h.trim().isNotEmpty).toList();
      
      final tips = _tipsController.text.trim().isEmpty 
          ? [] 
          : _tipsController.text.split('\n').where((t) => t.trim().isNotEmpty).toList();

      final guideData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim().isEmpty ? 'الجزائر' : _stateController.text.trim(),
        'country': _countryController.text.trim().isEmpty ? 'الجزائر' : _countryController.text.trim(),
        'latitude': _latitudeController.text.isNotEmpty 
            ? double.tryParse(_latitudeController.text) 
            : null,
        'longitude': _longitudeController.text.isNotEmpty 
            ? double.tryParse(_longitudeController.text) 
            : null,
        'category': _selectedCategory,
        'difficulty_level': _selectedDifficultyLevel,
        'best_season': _bestSeasonController.text.trim().isEmpty ? null : _bestSeasonController.text.trim(),
        'estimated_duration': _estimatedDurationController.text.trim().isEmpty ? null : _estimatedDurationController.text.trim(),
        'entry_fee': _entryFeeController.text.isNotEmpty 
            ? double.tryParse(_entryFeeController.text) 
            : 0,
        'currency': _currencyController.text.trim().isEmpty ? 'DZD' : _currencyController.text.trim(),
        'images': allImageUrls,
        'highlights': highlights,
        'tips': tips,
        'transportation_info': _transportationInfoController.text.trim().isEmpty ? null : _transportationInfoController.text.trim(),
        'contact_info': {},
        'opening_hours': {},
        'nearby_accommodations': [],
        'is_published': _isPublished,
        'is_featured': _isFeatured,
        'views_count': 0,
        'rating': 0.0,
        'total_reviews': 0,
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
              
              // Images Section
              _buildSectionCard(
                'الصور',
                [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'صور الدليل السياحي',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _testStorageConnection,
                        icon: const Icon(Icons.storage, size: 18),
                        label: const Text('اختبار التخزين'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _pickImages,
                        icon: const Icon(Icons.add_photo_alternate),
                        label: const Text('إضافة صور'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppStyles.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_selectedImages.isNotEmpty)
                    _buildImagePreview(),
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
                  _buildTextField(
                    controller: _countryController,
                    label: 'البلد',
                    hint: 'أدخل اسم البلد',
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
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    label: 'مستوى الصعوبة',
                    value: _selectedDifficultyLevel,
                    items: _difficultyLevels.map((level) => DropdownMenuItem(
                      value: level,
                      child: Text(
                        _difficultyLabels[level]!,
                        style: const TextStyle(fontFamily: 'Tajawal'),
                      ),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDifficultyLevel = value!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Additional Details Section
              _buildSectionCard(
                'تفاصيل إضافية',
                [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _bestSeasonController,
                          label: 'أفضل فصل',
                          hint: 'الربيع, الصيف, الخريف, الشتاء',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _estimatedDurationController,
                          label: 'المدة المقدرة',
                          hint: '2-3 ساعات, يوم واحد',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _entryFeeController,
                          label: 'رسوم الدخول',
                          hint: '0',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _currencyController,
                          label: 'العملة',
                          hint: 'DZD',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _transportationInfoController,
                    label: 'معلومات النقل',
                    hint: 'أدخل معلومات حول كيفية الوصول',
                    maxLines: 3,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Content Section
              _buildSectionCard(
                'المحتوى الإضافي',
                [
                  _buildTextField(
                    controller: _highlightsController,
                    label: 'النقاط المميزة',
                    hint: 'أدخل كل نقطة في سطر منفصل',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _tipsController,
                    label: 'نصائح للزوار',
                    hint: 'أدخل كل نصيحة في سطر منفصل',
                    maxLines: 4,
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
                  SwitchListTile(
                    title: const Text(
                      'دليل مميز',
                      style: TextStyle(fontFamily: 'Tajawal'),
                    ),
                    subtitle: const Text(
                      'عرض الدليل في القسم المميز',
                      style: TextStyle(fontFamily: 'Tajawal'),
                    ),
                    value: _isFeatured,
                    onChanged: (value) {
                      setState(() {
                        _isFeatured = value;
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

  Widget _buildImagePreview() {
    return Container(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedImages.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _selectedImages[index],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => _removeImage(index),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
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