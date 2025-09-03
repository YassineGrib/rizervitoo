import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/review.dart';
import '../services/admin_service.dart';
import '../constants/app_styles.dart';

class AdminReviewsScreen extends StatefulWidget {
  const AdminReviewsScreen({super.key});

  @override
  State<AdminReviewsScreen> createState() => _AdminReviewsScreenState();
}

class _AdminReviewsScreenState extends State<AdminReviewsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Review> _pendingReviews = [];
  List<Review> _verifiedReviews = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadReviews();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('Debug: AdminReviewsScreen - Starting to load reviews');
      
      final pendingReviews = await AdminService.getPendingReviews();
      print('Debug: AdminReviewsScreen - Pending reviews loaded: ${pendingReviews.length}');
      
      final verifiedReviews = await AdminService.getVerifiedReviews();
      print('Debug: AdminReviewsScreen - Verified reviews loaded: ${verifiedReviews.length}');

      setState(() {
        _pendingReviews = pendingReviews;
        _verifiedReviews = verifiedReviews;
        _isLoading = false;
      });
      
      print('Debug: AdminReviewsScreen - State updated successfully');
    } catch (e) {
      print('Debug: AdminReviewsScreen - Error loading reviews: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _approveReview(String reviewId) async {
    try {
      await AdminService.approveReview(reviewId);
      _loadReviews(); // Refresh the lists
      _showSuccessSnackBar('تم قبول التقييم بنجاح');
    } catch (e) {
      _showErrorSnackBar('فشل في قبول التقييم: ${e.toString()}');
    }
  }

  Future<void> _rejectReview(String reviewId) async {
    try {
      await AdminService.rejectReview(reviewId);
      _loadReviews(); // Refresh the lists
      _showSuccessSnackBar('تم رفض التقييم');
    } catch (e) {
      _showErrorSnackBar('فشل في رفض التقييم: ${e.toString()}');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Tajawal'),
        ),
        backgroundColor: const Color(0xFF27AE60),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Tajawal'),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'إدارة التقييمات',
          style: TextStyle(
            fontFamily: 'Amiri',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppStyles.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReviews,
            tooltip: 'تحديث',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.w600,
          ),
          tabs: [
            Tab(
              text: 'قيد المراجعة (${_pendingReviews.length})',
            ),
            Tab(
              text: 'المقبولة (${_verifiedReviews.length})',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorWidget()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPendingReviewsTab(),
                    _buildVerifiedReviewsTab(),
                  ],
                ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 16,
                color: Colors.red[300],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadReviews,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyles.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'إعادة المحاولة',
                style: TextStyle(fontFamily: 'Tajawal'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingReviewsTab() {
    if (_pendingReviews.isEmpty) {
      return _buildEmptyState(
        icon: Icons.pending_actions,
        title: 'لا توجد تقييمات قيد المراجعة',
        subtitle: 'جميع التقييمات تمت مراجعتها',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReviews,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pendingReviews.length,
        itemBuilder: (context, index) {
          final review = _pendingReviews[index];
          return _buildReviewCard(review, isPending: true);
        },
      ),
    );
  }

  Widget _buildVerifiedReviewsTab() {
    if (_verifiedReviews.isEmpty) {
      return _buildEmptyState(
        icon: Icons.verified,
        title: 'لا توجد تقييمات مقبولة',
        subtitle: 'لم يتم قبول أي تقييمات بعد',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReviews,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _verifiedReviews.length,
        itemBuilder: (context, index) {
          final review = _verifiedReviews[index];
          return _buildReviewCard(review, isPending: false);
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 16,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(Review review, {required bool isPending}) {
    final dateFormat = DateFormat('dd/MM/yyyy - HH:mm', 'ar');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Review Header
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppStyles.primaryColor.withOpacity(0.1),
                  child: review.guestAvatar != null
                      ? ClipOval(
                          child: Image.network(
                            review.guestAvatar!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.person,
                                color: AppStyles.primaryColor,
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.person,
                          color: AppStyles.primaryColor,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              index < review.rating
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 16,
                              color: const Color(0xFFF39C12),
                            );
                          }),
                          const SizedBox(width: 8),
                          Text(
                            dateFormat.format(review.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isPending)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'قيد المراجعة',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF27AE60).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'مقبول',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF27AE60),
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Accommodation Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.home,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      review.accommodationTitle ?? 'إقامة غير محددة',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Review Content
            if (review.title != null) ...[
              const SizedBox(height: 12),
              Text(
                review.title!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Tajawal',
                ),
              ),
            ],

            if (review.comment != null) ...[
              const SizedBox(height: 8),
              Text(
                review.comment!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                  fontFamily: 'Tajawal',
                ),
              ),
            ],

            // Detailed Ratings
            if (review.hasDetailedRatings) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (review.cleanlinessRating != null)
                    _buildDetailRatingChip('النظافة', review.cleanlinessRating!),
                  if (review.locationRating != null)
                    _buildDetailRatingChip('الموقع', review.locationRating!),
                  if (review.valueRating != null)
                    _buildDetailRatingChip('القيمة', review.valueRating!),
                  if (review.communicationRating != null)
                    _buildDetailRatingChip('التواصل', review.communicationRating!),
                ],
              ),
            ],

            // Action Buttons (only for pending reviews)
            if (isPending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showApprovalDialog(review),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text(
                        'قبول',
                        style: TextStyle(fontFamily: 'Tajawal'),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF27AE60),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showRejectionDialog(review),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text(
                        'رفض',
                        style: TextStyle(fontFamily: 'Tajawal'),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRatingChip(String label, int rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF39C12).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label $rating/5',
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFFF39C12),
          fontWeight: FontWeight.w500,
          fontFamily: 'Tajawal',
        ),
      ),
    );
  }

  void _showApprovalDialog(Review review) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'قبول التقييم',
          style: TextStyle(fontFamily: 'Amiri'),
        ),
        content: Text(
          'هل أنت متأكد من قبول هذا التقييم؟ سيصبح مرئياً للمستخدمين.',
          style: const TextStyle(fontFamily: 'Tajawal'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'إلغاء',
              style: TextStyle(fontFamily: 'Tajawal'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _approveReview(review.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF27AE60),
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'قبول',
              style: TextStyle(fontFamily: 'Tajawal'),
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectionDialog(Review review) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'رفض التقييم',
          style: TextStyle(fontFamily: 'Amiri'),
        ),
        content: Text(
          'هل أنت متأكد من رفض هذا التقييم؟ سيتم حذفه نهائياً.',
          style: const TextStyle(fontFamily: 'Tajawal'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'إلغاء',
              style: TextStyle(fontFamily: 'Tajawal'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _rejectReview(review.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'رفض',
              style: TextStyle(fontFamily: 'Tajawal'),
            ),
          ),
        ],
      ),
    );
  }
}