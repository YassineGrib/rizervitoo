import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/travel_agency.dart';
import '../../services/travel_agency_service.dart';
import '../../widgets/loading_widget.dart';

class AddEditTravelAgencyScreen extends StatefulWidget {
  final TravelAgency? agency;

  const AddEditTravelAgencyScreen({super.key, this.agency});

  @override
  State<AddEditTravelAgencyScreen> createState() => _AddEditTravelAgencyScreenState();
}

class _AddEditTravelAgencyScreenState extends State<AddEditTravelAgencyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  
  String? _selectedWilaya;
  List<AgencySpecialty> _selectedSpecialties = [];
  bool _isActive = true;
  bool _isVerified = false;
  bool _isLoading = false;
  
  bool get _isEditing => widget.agency != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _populateFields();
    }
  }

  void _populateFields() {
    final agency = widget.agency!;
    _nameController.text = agency.name;
    _descriptionController.text = agency.description ?? '';
    _addressController.text = agency.address;
    _phoneController.text = agency.phone;
    _emailController.text = agency.email ?? '';
    _websiteController.text = agency.website ?? '';
    _licenseNumberController.text = agency.licenseNumber ?? '';
    _selectedWilaya = agency.wilaya;
    _selectedSpecialties = agency.specialties
        .map((specialtyName) => _getSpecialtyFromName(specialtyName))
        .where((specialty) => specialty != null)
        .cast<AgencySpecialty>()
        .toList();
    _isActive = agency.isActive;
    _isVerified = agency.isVerified;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _licenseNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'تعديل الوكالة' : 'إضافة وكالة جديدة',
          style: const TextStyle(
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveAgency,
              child: const Text(
                'حفظ',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget()
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBasicInfoSection(),
                    const SizedBox(height: 24),
                    _buildContactInfoSection(),
                    const SizedBox(height: 24),
                    _buildLocationSection(),
                    const SizedBox(height: 24),
                    _buildSpecialtiesSection(),
                    const SizedBox(height: 24),
                    _buildStatusSection(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildSection(
      title: 'المعلومات الأساسية',
      icon: Icons.info,
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'اسم الوكالة *',
            hintText: 'أدخل اسم الوكالة السياحية',
            prefixIcon: Icon(Icons.business),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'اسم الوكالة مطلوب';
            }
            if (value.trim().length < 3) {
              return 'اسم الوكالة يجب أن يكون 3 أحرف على الأقل';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'وصف الوكالة',
            hintText: 'أدخل وصف مختصر عن الوكالة وخدماتها',
            prefixIcon: Icon(Icons.description),
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          maxLength: 500,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _licenseNumberController,
          decoration: const InputDecoration(
            labelText: 'رقم الترخيص',
            hintText: 'رقم ترخيص الوكالة السياحية',
            prefixIcon: Icon(Icons.badge),
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfoSection() {
    return _buildSection(
      title: 'معلومات الاتصال',
      icon: Icons.contact_phone,
      children: [
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'رقم الهاتف *',
            hintText: '0555123456',
            prefixIcon: Icon(Icons.phone),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'رقم الهاتف مطلوب';
            }
            if (value.length < 9) {
              return 'رقم الهاتف غير صحيح';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'البريد الإلكتروني',
            hintText: 'agency@example.com',
            prefixIcon: Icon(Icons.email),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value != null && value.trim().isNotEmpty) {
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'البريد الإلكتروني غير صحيح';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _websiteController,
          decoration: const InputDecoration(
            labelText: 'الموقع الإلكتروني',
            hintText: 'https://www.agency.com',
            prefixIcon: Icon(Icons.web),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.url,
          validator: (value) {
            if (value != null && value.trim().isNotEmpty) {
              if (Uri.tryParse(value)?.hasAbsolutePath != true) {
                return 'رابط الموقع غير صحيح';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return _buildSection(
      title: 'الموقع',
      icon: Icons.location_on,
      children: [
        DropdownButtonFormField<String>(
          value: _selectedWilaya,
          decoration: const InputDecoration(
            labelText: 'الولاية *',
            prefixIcon: Icon(Icons.location_city),
            border: OutlineInputBorder(),
          ),
          items: AlgerianWilayas.all.map((wilaya) {
            return DropdownMenuItem(
              value: wilaya,
              child: Text(wilaya),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedWilaya = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الولاية مطلوبة';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _addressController,
          decoration: const InputDecoration(
            labelText: 'العنوان التفصيلي *',
            hintText: 'الشارع، الحي، المدينة',
            prefixIcon: Icon(Icons.home),
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'العنوان مطلوب';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSpecialtiesSection() {
    return _buildSection(
      title: 'التخصصات',
      icon: Icons.category,
      children: [
        const Text(
          'اختر التخصصات التي تقدمها الوكالة:',
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AgencySpecialty.values.map((specialty) {
            final isSelected = _selectedSpecialties.contains(specialty);
            return FilterChip(
              label: Text(_getSpecialtyLabel(specialty)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedSpecialties.add(specialty);
                  } else {
                    _selectedSpecialties.remove(specialty);
                  }
                });
              },
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStatusSection() {
    return _buildSection(
      title: 'الحالة',
      icon: Icons.settings,
      children: [
        SwitchListTile(
          title: const Text('الوكالة مفعلة', style: TextStyle(fontFamily: 'Tajawal')),
          subtitle: const Text('يمكن للمستخدمين رؤية الوكالة والتفاعل معها', style: TextStyle(fontFamily: 'Tajawal')),
          value: _isActive,
          onChanged: (value) {
            setState(() {
              _isActive = value;
            });
          },
          activeColor: Theme.of(context).primaryColor,
        ),
        const Divider(),
        SwitchListTile(
          title: const Text('الوكالة معتمدة', style: TextStyle(fontFamily: 'Tajawal')),
          subtitle: const Text('الوكالة معتمدة رسمياً وموثوقة', style: TextStyle(fontFamily: 'Tajawal')),
          value: _isVerified,
          onChanged: (value) {
            setState(() {
              _isVerified = value;
            });
          },
          activeColor: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  String _getSpecialtyLabel(AgencySpecialty specialty) {
    switch (specialty) {
      case AgencySpecialty.domestic:
        return 'السياحة الداخلية';
      case AgencySpecialty.international:
        return 'السياحة الخارجية';
      case AgencySpecialty.umrah:
        return 'عمرة';
      case AgencySpecialty.hajj:
        return 'حج';
      case AgencySpecialty.business:
        return 'سياحة الأعمال';
      case AgencySpecialty.adventure:
        return 'سياحة المغامرات';
      case AgencySpecialty.cultural:
        return 'السياحة الثقافية';
      case AgencySpecialty.medical:
        return 'السياحة العلاجية';
      case AgencySpecialty.educational:
        return 'السياحة التعليمية';
    }
  }

  AgencySpecialty? _getSpecialtyFromName(String name) {
    try {
      return AgencySpecialty.values.firstWhere((specialty) => specialty.name == name);
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveAgency() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedWilaya == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار الولاية'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final agencyData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        'address': _addressController.text.trim(),
        'wilaya': _selectedWilaya!,
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        'website': _websiteController.text.trim().isEmpty
            ? null
            : _websiteController.text.trim(),
        'license_number': _licenseNumberController.text.trim().isEmpty
            ? null
            : _licenseNumberController.text.trim(),
        'specialties': _selectedSpecialties.map((s) => s.name).toList(),
        'is_active': _isActive,
        'is_verified': _isVerified,
      };

      if (_isEditing) {
        await TravelAgencyService.updateAgency(widget.agency!.id, agencyData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تحديث الوكالة بنجاح', style: TextStyle(fontFamily: 'Tajawal')),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await TravelAgencyService.createAgency(agencyData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إنشاء الوكالة بنجاح', style: TextStyle(fontFamily: 'Tajawal')),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${e.toString()}', style: const TextStyle(fontFamily: 'Tajawal')),
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
}