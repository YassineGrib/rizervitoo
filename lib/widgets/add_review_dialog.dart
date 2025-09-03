import 'package:flutter/material.dart';
import '../models/review.dart';
import '../services/review_service.dart';
import '../constants/app_styles.dart';

class AddReviewDialog extends StatefulWidget {
  final String accommodationId;
  final String? bookingId;
  final Function(Review)? onReviewAdded;
  
  const AddReviewDialog({
    super.key,
    required this.accommodationId,
    this.bookingId,
    this.onReviewAdded,
  });

  @override
  State<AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends State<AddReviewDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _commentController = TextEditingController();
  
  int _overallRating = 5;
  int? _cleanlinessRating;
  int? _locationRating;
  int? _valueRating;
  int? _communicationRating;
  
  bool _isSubmitting = false;
  bool _showDetailedRatings = false;

  @override
  void dispose() {
    _titleController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'إضافة تقييم',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.headlineSmall?.color,
                          fontFamily: 'Amiri',
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Overall Rating
                        Text(
                          'التقييم العام *',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.headlineSmall?.color,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildRatingSelector(
                          _overallRating,
                          (rating) => setState(() => _overallRating = rating),
                          size: 32,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getRatingText(_overallRating),
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppStyles.darkPrimaryColor
                                : AppStyles.primaryColor,
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Title
                        Text(
                          'عنوان التقييم',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.headlineSmall?.color,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _titleController,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                          ),
                          decoration: InputDecoration(
                            hintText: 'ملخص سريع لتجربتك',
                            hintStyle: TextStyle(
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                              fontFamily: 'Tajawal',
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[600]!
                                    : Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? AppStyles.darkPrimaryColor
                                    : AppStyles.primaryColor,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[800]
                                : Colors.grey[50],
                          ),
                          maxLength: 100,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Comment
                        Text(
                          'تعليقك *',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.headlineSmall?.color,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _commentController,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                          ),
                          decoration: InputDecoration(
                            hintText: 'شاركنا تفاصيل تجربتك في هذه الإقامة...',
                            hintStyle: TextStyle(
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                              fontFamily: 'Tajawal',
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[600]!
                                    : Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? AppStyles.darkPrimaryColor
                                    : AppStyles.primaryColor,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[800]
                                : Colors.grey[50],
                          ),
                          maxLines: 4,
                          maxLength: 500,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'يرجى كتابة تعليقك';
                            }
                            if (value.trim().length < 10) {
                              return 'يجب أن يكون التعليق 10 أحرف على الأقل';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Detailed Ratings Toggle
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _showDetailedRatings = !_showDetailedRatings;
                                if (!_showDetailedRatings) {
                                  // Reset detailed ratings when hiding
                                  _cleanlinessRating = null;
                                  _locationRating = null;
                                  _valueRating = null;
                                  _communicationRating = null;
                                }
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.grey[600]!
                                      : Colors.grey.shade300,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _showDetailedRatings
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? AppStyles.darkPrimaryColor
                                        : AppStyles.primaryColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'التقييمات التفصيلية (اختيارية)',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? AppStyles.darkPrimaryColor
                                          : AppStyles.primaryColor,
                                      fontFamily: 'Tajawal',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        // Detailed Ratings
                        if (_showDetailedRatings) ...[
                          const SizedBox(height: 20),
                          _buildDetailedRatingSection(),
                        ],
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.pop(context),
                        child: Text(
                          'إلغاء',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitReview,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).brightness == Brightness.dark
                              ? AppStyles.darkPrimaryColor
                              : AppStyles.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'إرسال التقييم',
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRatingSelector(int currentRating, Function(int) onRatingChanged, {double size = 24}) {
    return Row(
      children: List.generate(5, (index) {
        final ratingValue = index + 1;
        return GestureDetector(
          onTap: () => onRatingChanged(ratingValue),
          child: Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Icon(
              ratingValue <= currentRating
                  ? Icons.star
                  : Icons.star_border,
              size: size,
              color: ratingValue <= currentRating
                  ? const Color(0xFFF39C12)
                  : Colors.grey.shade400,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDetailedRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cleanliness
        _buildDetailedRatingItem(
          'النظافة',
          Icons.cleaning_services,
          _cleanlinessRating ?? 0,
          (rating) => setState(() => _cleanlinessRating = rating),
        ),
        const SizedBox(height: 16),
        
        // Location
        _buildDetailedRatingItem(
          'الموقع',
          Icons.location_on,
          _locationRating ?? 0,
          (rating) => setState(() => _locationRating = rating),
        ),
        const SizedBox(height: 16),
        
        // Value
        _buildDetailedRatingItem(
          'القيمة مقابل السعر',
          Icons.attach_money,
          _valueRating ?? 0,
          (rating) => setState(() => _valueRating = rating),
        ),
        const SizedBox(height: 16),
        
        // Communication
        _buildDetailedRatingItem(
          'التواصل',
          Icons.chat,
          _communicationRating ?? 0,
          (rating) => setState(() => _communicationRating = rating),
        ),
      ],
    );
  }

  Widget _buildDetailedRatingItem(
    String title,
    IconData icon,
    int currentRating,
    Function(int) onRatingChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[700]!
              : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppStyles.darkPrimaryColor
                    : AppStyles.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.headlineSmall?.color,
                  fontFamily: 'Tajawal',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildRatingSelector(
            currentRating,
            onRatingChanged,
            size: 20,
          ),
        ],
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'سيء جداً';
      case 2:
        return 'سيء';
      case 3:
        return 'متوسط';
      case 4:
        return 'جيد';
      case 5:
        return 'ممتاز';
      default:
        return 'غير محدد';
    }
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final review = await ReviewService.addReview(
        bookingId: widget.bookingId,
        accommodationId: widget.accommodationId,
        rating: _overallRating,
        title: _titleController.text.trim().isNotEmpty
            ? _titleController.text.trim()
            : null,
        comment: _commentController.text.trim(),
        cleanlinessRating: _cleanlinessRating,
        locationRating: _locationRating,
        valueRating: _valueRating,
        communicationRating: _communicationRating,
      );

      if (widget.onReviewAdded != null) {
        widget.onReviewAdded!(review);
      }

      Navigator.pop(context);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم إرسال تقييمك بنجاح! سيظهر بعد المراجعة.',
            style: TextStyle(fontFamily: 'Tajawal'),
          ),
          backgroundColor: Color(0xFF27AE60),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حدث خطأ أثناء إرسال التقييم: ${e.toString()}',
            style: const TextStyle(fontFamily: 'Tajawal'),
          ),
          backgroundColor: const Color(0xFFE74C3C),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}