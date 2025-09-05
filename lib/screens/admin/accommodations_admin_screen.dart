import 'package:flutter/material.dart';
import 'package:rizervitoo/services/admin_service.dart';
import 'package:rizervitoo/widgets/custom_app_bar.dart';
import 'package:rizervitoo/widgets/loading_widget.dart';
import 'package:rizervitoo/widgets/error_widget.dart';
import 'package:rizervitoo/utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AccommodationsAdminScreen extends StatefulWidget {
  const AccommodationsAdminScreen({Key? key}) : super(key: key);

  @override
  State<AccommodationsAdminScreen> createState() => _AccommodationsAdminScreenState();
}

class _AccommodationsAdminScreenState extends State<AccommodationsAdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _pendingAccommodations = [];
  List<Map<String, dynamic>> _allAccommodations = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final pendingFuture = AdminService.getPendingAccommodations();
      final allFuture = AdminService.getAllAccommodations();

      final results = await Future.wait([pendingFuture, allFuture]);
      
      setState(() {
        _pendingAccommodations = results[0];
        _allAccommodations = results[1];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _approveAccommodation(String accommodationId) async {
    try {
      await AdminService.approveAccommodation(accommodationId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم قبول الاستضافة بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
      _loadData(); // Refresh data
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في قبول الاستضافة: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _rejectAccommodation(String accommodationId) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الرفض'),
        content: const Text('هل أنت متأكد من رفض هذه الاستضافة؟ سيتم حذفها نهائياً.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('رفض'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await AdminService.rejectAccommodation(accommodationId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم رفض الاستضافة بنجاح'),
            backgroundColor: Colors.orange,
          ),
        );
        _loadData(); // Refresh data
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في رفض الاستضافة: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleAvailability(String accommodationId, bool currentAvailability) async {
    try {
      await AdminService.toggleAccommodationAvailability(accommodationId, !currentAvailability);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(currentAvailability ? 'تم إيقاف الاستضافة' : 'تم تفعيل الاستضافة'),
          backgroundColor: Colors.blue,
        ),
      );
      _loadData(); // Refresh data
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تغيير حالة الاستضافة: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'إدارة الاستضافات',
        showBackButton: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              text: 'قيد المراجعة (${_pendingAccommodations.length})',
            ),
            Tab(
              text: 'جميع الاستضافات (${_allAccommodations.length})',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _error != null
              ? CustomErrorWidget(
                  message: _error!,
                  onRetry: _loadData,
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPendingAccommodationsList(),
                    _buildAllAccommodationsList(),
                  ],
                ),
    );
  }

  Widget _buildPendingAccommodationsList() {
    if (_pendingAccommodations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'لا توجد استضافات قيد المراجعة',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pendingAccommodations.length,
        itemBuilder: (context, index) {
          final accommodation = _pendingAccommodations[index];
          return _buildAccommodationCard(accommodation, isPending: true);
        },
      ),
    );
  }

  Widget _buildAllAccommodationsList() {
    if (_allAccommodations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'لا توجد استضافات',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _allAccommodations.length,
        itemBuilder: (context, index) {
          final accommodation = _allAccommodations[index];
          return _buildAccommodationCard(accommodation, isPending: false);
        },
      ),
    );
  }

  Widget _buildAccommodationCard(Map<String, dynamic> accommodation, {required bool isPending}) {
    final isVerified = accommodation['is_verified'] ?? false;
    final isAvailable = accommodation['is_available'] ?? true;
    final images = accommodation['images'] as List<dynamic>? ?? [];
    final firstImage = images.isNotEmpty ? images[0] : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status badges
            Row(
              children: [
                Expanded(
                  child: Text(
                    accommodation['title'] ?? 'بدون عنوان',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (!isVerified)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'قيد المراجعة',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                if (isVerified)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isAvailable ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isAvailable ? 'متاح' : 'غير متاح',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Image and details
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                if (firstImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: firstImage,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image),
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'النوع: ${_getAccommodationTypeInArabic(accommodation['type'])}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'السعر: ${accommodation['price_per_night']} ريال/ليلة',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'المالك: ${accommodation['owner_name'] ?? 'غير محدد'}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      if (accommodation['owner_phone'] != null)
                        Text(
                          'الهاتف: ${accommodation['owner_phone']}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Description
            if (accommodation['description'] != null)
              Text(
                accommodation['description'],
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              children: [
                if (isPending) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _approveAccommodation(accommodation['id']),
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: const Text('قبول', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _rejectAccommodation(accommodation['id']),
                      icon: const Icon(Icons.close, color: Colors.white),
                      label: const Text('رفض', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ),
                ] else ...[
                  if (isVerified)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _toggleAvailability(accommodation['id'], isAvailable),
                        icon: Icon(
                          isAvailable ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white,
                        ),
                        label: Text(
                          isAvailable ? 'إيقاف' : 'تفعيل',
                          style: const TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isAvailable ? Colors.orange : Colors.blue,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getAccommodationTypeInArabic(String? type) {
    switch (type) {
      case 'hotel':
        return 'فندق';
      case 'house':
        return 'منزل';
      case 'apartment':
        return 'شقة';
      case 'villa':
        return 'فيلا';
      case 'guesthouse':
        return 'بيت ضيافة';
      case 'hostel':
        return 'نزل';
      default:
        return type ?? 'غير محدد';
    }
  }
}