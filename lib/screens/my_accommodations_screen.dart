import 'package:flutter/material.dart';
import '../models/accommodation.dart';
import '../services/accommodation_service.dart';
import '../constants/app_styles.dart';
import 'add_edit_accommodation_screen.dart';

class MyAccommodationsScreen extends StatefulWidget {
  const MyAccommodationsScreen({super.key});

  @override
  State<MyAccommodationsScreen> createState() => _MyAccommodationsScreenState();
}

class _MyAccommodationsScreenState extends State<MyAccommodationsScreen> {
  final AccommodationService _accommodationService = AccommodationService();
  List<Accommodation> _myAccommodations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMyAccommodations();
  }

  Future<void> _loadMyAccommodations() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Get current user's accommodations
      final accommodations = await _accommodationService.getHostAccommodations();
      
      setState(() {
        _myAccommodations = accommodations;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل الاستضافات: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteAccommodation(String accommodationId) async {
    try {
      await _accommodationService.deleteAccommodation(accommodationId);
      await _loadMyAccommodations(); // Refresh the list
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف الاستضافة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في حذف الاستضافة: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation(Accommodation accommodation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'تأكيد الحذف',
            style: TextStyle(fontFamily: 'Tajawal'),
          ),
          content: Text(
            'هل أنت متأكد من حذف استضافة "${accommodation.title}"؟',
            style: const TextStyle(fontFamily: 'Tajawal'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'إلغاء',
                style: TextStyle(fontFamily: 'Tajawal'),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAccommodation(accommodation.id);
              },
              child: const Text(
                'حذف',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Column(
          children: [
            // Custom Header Section
            Container(
               padding: EdgeInsets.only(
                 top: MediaQuery.of(context).padding.top + 3,
                 left: 10,
                 right: 10,
                 bottom: 0,
               ),
              decoration: BoxDecoration(
                color: AppStyles.primaryColor,
                // borderRadius: const BorderRadius.only(
                //   bottomLeft: Radius.circular(20),
                //   bottomRight: Radius.circular(20),
                // ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'استضافاتي',
                      style: AppStyles.appBarTitleStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AddEditAccommodationScreen(),
                        ),
                      );
                      
                      if (result == true) {
                        _loadMyAccommodations(); // Refresh the list
                      }
                    },
                  ),
                ],
              ),
            ),
            // Body Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _myAccommodations.isEmpty
                      ? _buildEmptyState()
                      : _buildAccommodationsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.home_work_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد استضافات حتى الآن',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ بإضافة استضافتك الأولى',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AddEditAccommodationScreen(),
                ),
              );
              
              if (result == true) {
                _loadMyAccommodations();
              }
            },
            icon: const Icon(Icons.add),
            label: const Text(
              'إضافة استضافة جديدة',
              style: TextStyle(fontFamily: 'Tajawal'),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccommodationsList() {
    return RefreshIndicator(
      onRefresh: _loadMyAccommodations,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _myAccommodations.length,
        itemBuilder: (context, index) {
          final accommodation = _myAccommodations[index];
          return _buildAccommodationCard(accommodation);
        },
      ),
    );
  }

  Widget _buildAccommodationCard(Accommodation accommodation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
              ),
              child: accommodation.images.isNotEmpty
                  ? Image.network(
                      accommodation.images.first,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey.shade400,
                          ),
                        );
                      },
                    )
                  : Icon(
                      Icons.home_work,
                      size: 50,
                      color: Colors.grey.shade400,
                    ),
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        accommodation.title,
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AddEditAccommodationScreen(
                                accommodation: accommodation,
                              ),
                            ),
                          ).then((result) {
                            if (result == true) {
                              _loadMyAccommodations();
                            }
                          });
                        } else if (value == 'delete') {
                          _showDeleteConfirmation(accommodation);
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'تعديل',
                                style: TextStyle(fontFamily: 'Tajawal'),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'حذف',
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${accommodation.city}, ${accommodation.country}',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '\$${accommodation.pricePerNight.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const Text(
                      ' / ليلة',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: accommodation.isAvailable
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        accommodation.isAvailable ? 'متاح' : 'غير متاح',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: accommodation.isAvailable
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}