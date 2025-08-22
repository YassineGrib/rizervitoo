import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../models/accommodation.dart';
import '../services/accommodation_service.dart';
import '../services/image_picker_service.dart';
import '../constants/app_styles.dart';

class AddEditAccommodationScreen extends StatefulWidget {
  final Accommodation? accommodation;
  
  const AddEditAccommodationScreen({super.key, this.accommodation});

  @override
  State<AddEditAccommodationScreen> createState() => _AddEditAccommodationScreenState();
}

class _AddEditAccommodationScreenState extends State<AddEditAccommodationScreen> {
  final _formKey = GlobalKey<FormState>();
  final AccommodationService _accommodationService = AccommodationService();
  final ImagePickerService _imagePickerService = ImagePickerService();
  
  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _priceController = TextEditingController();
  final _maxGuestsController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  
  // Form data
  String _selectedType = 'apartment';
  bool _isAvailable = true;
  List<String> _amenities = [];
  List<File> _selectedImages = [];
  List<String> _existingImageUrls = [];
  bool _isLoading = false;
  
  // Available amenities
  final List<Map<String, dynamic>> _availableAmenities = [
    {'key': 'wifi', 'label': 'واي فاي', 'icon': Icons.wifi},
    {'key': 'parking', 'label': 'موقف سيارات', 'icon': Icons.local_parking},
    {'key': 'pool', 'label': 'مسبح', 'icon': Icons.pool},
    {'key': 'gym', 'label': 'صالة رياضية', 'icon': Icons.fitness_center},
    {'key': 'kitchen', 'label': 'مطبخ', 'icon': Icons.kitchen},
    {'key': 'ac', 'label': 'تكييف', 'icon': Icons.ac_unit},
    {'key': 'tv', 'label': 'تلفزيون', 'icon': Icons.tv},
    {'key': 'washing_machine', 'label': 'غسالة', 'icon': Icons.local_laundry_service},
    {'key': 'balcony', 'label': 'شرفة', 'icon': Icons.balcony},
    {'key': 'elevator', 'label': 'مصعد', 'icon': Icons.elevator},
  ];
  
  // Accommodation types
  final List<Map<String, String>> _accommodationTypes = [
    {'key': 'apartment', 'label': 'شقة'},
    {'key': 'house', 'label': 'منزل'},
    {'key': 'villa', 'label': 'فيلا'},
    {'key': 'studio', 'label': 'استوديو'},
    {'key': 'room', 'label': 'غرفة'},
    {'key': 'hotel', 'label': 'فندق'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.accommodation != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    final acc = widget.accommodation!;
    _titleController.text = acc.title;
    _descriptionController.text = acc.description ?? '';
    _addressController.text = acc.address;
    _cityController.text = acc.city;
    _countryController.text = acc.country;
    _priceController.text = acc.pricePerNight.toString();
    _maxGuestsController.text = acc.maxGuests.toString();
    _bedroomsController.text = acc.bedrooms.toString();
    _bathroomsController.text = acc.bathrooms.toString();
    _selectedType = acc.type;
    _isAvailable = acc.isAvailable;
    _amenities = List.from(acc.amenities);
    _existingImageUrls = List.from(acc.images);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _priceController.dispose();
    _maxGuestsController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final images = await _imagePickerService.pickMultipleImages();
      setState(() {
        _selectedImages.addAll(images);
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في اختيار الصور: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeImage(int index, {bool isExisting = false}) {
    setState(() {
      if (isExisting) {
        _existingImageUrls.removeAt(index);
      } else {
        _selectedImages.removeAt(index);
      }
    });
  }

  void _toggleAmenity(String amenity) {
    setState(() {
      if (_amenities.contains(amenity)) {
        _amenities.remove(amenity);
      } else {
        _amenities.add(amenity);
      }
    });
  }

  Future<void> _saveAccommodation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImages.isEmpty && _existingImageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إضافة صورة واحدة على الأقل'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload new images
      List<String> uploadedImageUrls = [];
      if (_selectedImages.isNotEmpty) {
        uploadedImageUrls = await _accommodationService.uploadImages(_selectedImages);
      }

      // Combine existing and new image URLs
      final allImageUrls = [..._existingImageUrls, ...uploadedImageUrls];

      final accommodation = Accommodation(
        id: widget.accommodation?.id ?? '',
        ownerId: widget.accommodation?.ownerId ?? '', // Will be set by the service
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _selectedType,
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        state: widget.accommodation?.state ?? 'الجزائر',
        country: _countryController.text.trim(),
        latitude: widget.accommodation?.latitude,
        longitude: widget.accommodation?.longitude,
        pricePerNight: double.parse(_priceController.text),
        currency: widget.accommodation?.currency ?? 'DZD',
        maxGuests: int.parse(_maxGuestsController.text),
        bedrooms: int.parse(_bedroomsController.text),
        bathrooms: int.parse(_bathroomsController.text),
        amenities: _amenities,
        images: allImageUrls,
        isAvailable: _isAvailable,
        isVerified: widget.accommodation?.isVerified ?? false,
        rating: widget.accommodation?.rating ?? 0.0,
        totalReviews: widget.accommodation?.totalReviews ?? 0,
        createdAt: widget.accommodation?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.accommodation != null) {
        await _accommodationService.updateAccommodation(accommodation);
      } else {
        await _accommodationService.createAccommodation(accommodation);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.accommodation != null
                  ? 'تم تحديث الاستضافة بنجاح'
                  : 'تم إضافة الاستضافة بنجاح',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في حفظ الاستضافة: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.accommodation != null ? 'تعديل الاستضافة' : 'إضافة استضافة جديدة',
          style: AppStyles.appBarTitleStyleDark,
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppStyles.textPrimaryColor,
        elevation: 1,
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveAccommodation,
              child: const Text(
                'حفظ',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildBasicInfoSection(),
            const SizedBox(height: 24),
            _buildLocationSection(),
            const SizedBox(height: 24),
            _buildDetailsSection(),
            const SizedBox(height: 24),
            _buildImagesSection(),
            const SizedBox(height: 24),
            _buildAmenitiesSection(),
            const SizedBox(height: 24),
            _buildAvailabilitySection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'المعلومات الأساسية',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'عنوان الاستضافة',
                labelStyle: TextStyle(fontFamily: 'Tajawal'),
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontFamily: 'Tajawal'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال عنوان الاستضافة';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'الوصف',
                labelStyle: TextStyle(fontFamily: 'Tajawal'),
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontFamily: 'Tajawal'),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال وصف الاستضافة';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'نوع الاستضافة',
                labelStyle: TextStyle(fontFamily: 'Tajawal'),
                border: OutlineInputBorder(),
              ),
              items: _accommodationTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type['key'],
                  child: Text(
                    type['label']!,
                    style: const TextStyle(fontFamily: 'Tajawal'),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الموقع',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'العنوان',
                labelStyle: TextStyle(fontFamily: 'Tajawal'),
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontFamily: 'Tajawal'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال العنوان';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'المدينة',
                      labelStyle: TextStyle(fontFamily: 'Tajawal'),
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(fontFamily: 'Tajawal'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال المدينة';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _countryController,
                    decoration: const InputDecoration(
                      labelText: 'الدولة',
                      labelStyle: TextStyle(fontFamily: 'Tajawal'),
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(fontFamily: 'Tajawal'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال الدولة';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'التفاصيل',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'السعر لكل ليلة (\$)',
                labelStyle: TextStyle(fontFamily: 'Tajawal'),
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontFamily: 'Tajawal'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال السعر';
                }
                if (double.tryParse(value) == null || double.parse(value) <= 0) {
                  return 'يرجى إدخال سعر صحيح';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _maxGuestsController,
                    decoration: const InputDecoration(
                      labelText: 'عدد الضيوف الأقصى',
                      labelStyle: TextStyle(fontFamily: 'Tajawal'),
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(fontFamily: 'Tajawal'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال عدد الضيوف';
                      }
                      if (int.tryParse(value) == null || int.parse(value) <= 0) {
                        return 'يرجى إدخال عدد صحيح';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _bedroomsController,
                    decoration: const InputDecoration(
                      labelText: 'عدد غرف النوم',
                      labelStyle: TextStyle(fontFamily: 'Tajawal'),
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(fontFamily: 'Tajawal'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال عدد غرف النوم';
                      }
                      if (int.tryParse(value) == null || int.parse(value) < 0) {
                        return 'يرجى إدخال عدد صحيح';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bathroomsController,
              decoration: const InputDecoration(
                labelText: 'عدد الحمامات',
                labelStyle: TextStyle(fontFamily: 'Tajawal'),
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontFamily: 'Tajawal'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال عدد الحمامات';
                }
                if (int.tryParse(value) == null || int.parse(value) < 0) {
                  return 'يرجى إدخال عدد صحيح';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'الصور',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text(
                    'إضافة صور',
                    style: TextStyle(fontFamily: 'Tajawal'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_existingImageUrls.isEmpty && _selectedImages.isEmpty)
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate,
                      size: 40,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'لم يتم إضافة صور بعد',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // Existing images
                    ..._existingImageUrls.asMap().entries.map((entry) {
                      final index = entry.key;
                      final imageUrl = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                imageUrl,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 120,
                                    height: 120,
                                    color: Colors.grey.shade200,
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Colors.grey.shade400,
                                    ),
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _removeImage(index, isExisting: true),
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
                    }).toList(),
                    // New selected images
                    ..._selectedImages.asMap().entries.map((entry) {
                      final index = entry.key;
                      final image = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                image,
                                width: 120,
                                height: 120,
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
                    }).toList(),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmenitiesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'المرافق والخدمات',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableAmenities.map((amenity) {
                final isSelected = _amenities.contains(amenity['key']);
                return FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        amenity['icon'],
                        size: 16,
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        amenity['label'],
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          color: isSelected ? Colors.white : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) => _toggleAmenity(amenity['key']),
                  selectedColor: Colors.blue.shade600,
                  checkmarkColor: Colors.white,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilitySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الإتاحة',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text(
                'متاح للحجز',
                style: TextStyle(fontFamily: 'Tajawal'),
              ),
              subtitle: Text(
                _isAvailable
                    ? 'الاستضافة متاحة للحجز حالياً'
                    : 'الاستضافة غير متاحة للحجز حالياً',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  color: Colors.grey.shade600,
                ),
              ),
              value: _isAvailable,
              onChanged: (value) {
                setState(() {
                  _isAvailable = value;
                });
              },
              activeColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}