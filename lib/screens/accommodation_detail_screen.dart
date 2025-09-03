import 'package:flutter/material.dart';
import '../models/accommodation.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';
import '../constants/app_styles.dart';

class AccommodationDetailScreen extends StatefulWidget {
  final Accommodation accommodation;

  const AccommodationDetailScreen({
    super.key,
    required this.accommodation,
  });

  @override
  State<AccommodationDetailScreen> createState() => _AccommodationDetailScreenState();
}

class _AccommodationDetailScreenState extends State<AccommodationDetailScreen> {
  final PageController _pageController = PageController();
  final BookingService _bookingService = BookingService();
  int _currentImageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: CustomScrollView(
          slivers: [
            // App Bar with Images
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? AppStyles.darkPrimaryColor
                  : AppStyles.primaryColor,
              foregroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildImageGallery(),
              ),
            ),
            
            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Type
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.accommodation.title,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.headlineSmall?.color,
                              fontFamily: 'Amiri',
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: (Theme.of(context).brightness == Brightness.dark
                                ? AppStyles.darkPrimaryColor
                                : AppStyles.primaryColor).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.accommodation.typeDisplayName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? AppStyles.darkPrimaryColor
                                  : AppStyles.primaryColor,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 20,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppStyles.darkPrimaryColor
                              : AppStyles.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.accommodation.address,
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      '${widget.accommodation.city}, ${widget.accommodation.state}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Rating and Reviews
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF39C12).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                size: 16,
                                color: Color(0xFFF39C12),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.accommodation.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFF39C12),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${widget.accommodation.totalReviews} تقييم',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Guest Info Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            Icons.people_outline,
                            '${widget.accommodation.maxGuests}',
                            'ضيوف',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInfoCard(
                            Icons.bed_outlined,
                            '${widget.accommodation.bedrooms}',
                            'غرف نوم',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInfoCard(
                            Icons.bathroom_outlined,
                            '${widget.accommodation.bathrooms}',
                            'حمامات',
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Description
                    if (widget.accommodation.description != null) ...[
                      Text(
                        'الوصف',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.headlineSmall?.color,
                          fontFamily: 'Amiri',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.accommodation.description!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          height: 1.5,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    // Amenities
                    if (widget.accommodation.amenities.isNotEmpty) ...[
                      Text(
                        'المرافق والخدمات',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.headlineSmall?.color,
                          fontFamily: 'Amiri',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.accommodation.amenities.map((amenity) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF27AE60).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF27AE60).withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              amenity,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF27AE60),
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Tajawal',
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    // Price Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[800]
                            : const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[700]!
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.accommodation.formattedPrice,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF27AE60),
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                              const Text(
                                'لكل ليلة',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF7F8C8D),
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _showBookingDialog();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).brightness == Brightness.dark
                                  ? AppStyles.darkPrimaryColor
                                  : const Color(0xFF3498DB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'احجز الآن',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Tajawal',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery() {
    if (widget.accommodation.images.isEmpty) {
      return Container(
        color: Colors.grey.shade200,
        child: const Center(
          child: Icon(
            Icons.home_outlined,
            size: 80,
            color: Color(0xFF7F8C8D),
          ),
        ),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemCount: widget.accommodation.images.length,
          itemBuilder: (context, index) {
            return Image.network(
              widget.accommodation.images[index],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 50,
                      color: Color(0xFF7F8C8D),
                    ),
                  ),
                );
              },
            );
          },
        ),
        
        // Image indicators
        if (widget.accommodation.images.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.accommodation.images.asMap().entries.map((entry) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == entry.key
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[700]!
              : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 24,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppStyles.darkPrimaryColor
                : AppStyles.primaryColor,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.headlineSmall?.color,
              fontFamily: 'Tajawal',
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingDialog() {
    DateTime? checkInDate;
    DateTime? checkOutDate;
    int guestCount = 1;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            title: Text(
              'حجز الإقامة',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.headlineSmall?.color,
                fontFamily: 'Amiri',
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تفاصيل الحجز لـ "${widget.accommodation.title}"',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Check-in Date
                  Text(
                    'تاريخ الوصول:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.headlineSmall?.color,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          checkInDate = date;
                        });
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[600]!
                              : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[800]
                            : Colors.white,
                      ),
                      child: Text(
                        checkInDate != null
                            ? '${checkInDate!.day}/${checkInDate!.month}/${checkInDate!.year}'
                            : 'اختر تاريخ الوصول',
                        style: TextStyle(
                          fontSize: 14,
                          color: checkInDate != null 
                              ? Theme.of(context).textTheme.bodyLarge?.color 
                              : Theme.of(context).textTheme.bodyMedium?.color,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Check-out Date
                  Text(
                    'تاريخ المغادرة:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.headlineSmall?.color,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: checkInDate?.add(const Duration(days: 1)) ?? DateTime.now().add(const Duration(days: 1)),
                        firstDate: checkInDate?.add(const Duration(days: 1)) ?? DateTime.now().add(const Duration(days: 1)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          checkOutDate = date;
                        });
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[600]!
                              : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[800]
                            : Colors.white,
                      ),
                      child: Text(
                        checkOutDate != null
                            ? '${checkOutDate!.day}/${checkOutDate!.month}/${checkOutDate!.year}'
                            : 'اختر تاريخ المغادرة',
                        style: TextStyle(
                          fontSize: 14,
                          color: checkOutDate != null 
                              ? Theme.of(context).textTheme.bodyLarge?.color 
                              : Theme.of(context).textTheme.bodyMedium?.color,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Guest Count
                  Text(
                    'عدد الضيوف:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.headlineSmall?.color,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        onPressed: guestCount > 1 ? () {
                          setState(() {
                            guestCount--;
                          });
                        } : null,
                        icon: const Icon(Icons.remove_circle_outline),
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppStyles.darkPrimaryColor
                            : const Color(0xFF3498DB),
                      ),
                      Expanded(
                        child: Text(
                          '$guestCount ضيف',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.headlineSmall?.color,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: guestCount < widget.accommodation.maxGuests ? () {
                          setState(() {
                            guestCount++;
                          });
                        } : null,
                        icon: const Icon(Icons.add_circle_outline),
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppStyles.darkPrimaryColor
                            : const Color(0xFF3498DB),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Price Summary
                  if (checkInDate != null && checkOutDate != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[800]
                            : const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'عدد الليالي:',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).textTheme.bodyMedium?.color,
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                              Text(
                                '${checkOutDate!.difference(checkInDate!).inDays} ليلة',
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'السعر الإجمالي:',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).textTheme.bodyMedium?.color,
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                              Text(
                                '${(widget.accommodation.pricePerNight * checkOutDate!.difference(checkInDate!).inDays).toStringAsFixed(0)} دج',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF27AE60),
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'إلغاء',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: (checkInDate != null && checkOutDate != null) ? () {
                  Navigator.pop(context);
                  _showBookingConfirmation(checkInDate!, checkOutDate!, guestCount);
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).brightness == Brightness.dark
                      ? AppStyles.darkPrimaryColor
                      : const Color(0xFF3498DB),
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'تأكيد الحجز',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBookingConfirmation(DateTime checkIn, DateTime checkOut, int guests) async {
    final nights = checkOut.difference(checkIn).inDays;
    final totalPrice = widget.accommodation.pricePerNight * nights;
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppStyles.darkPrimaryColor
                    : AppStyles.primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'جاري حفظ الحجز...',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    
    try {
      // Create booking request
      final bookingRequest = BookingRequest(
        accommodationId: widget.accommodation.id,
        checkInDate: checkIn,
        checkOutDate: checkOut,
        guestsCount: guests,
        pricePerNight: widget.accommodation.pricePerNight,
      );
      
      // Save booking to database
      await _bookingService.createBooking(bookingRequest);
      
      // Close loading dialog
      Navigator.pop(context);
      
      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            title: const Text(
              'تم الحجز بنجاح!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF27AE60),
                fontFamily: 'Amiri',
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF27AE60),
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'تم حفظ حجزك بنجاح!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                    fontFamily: 'Amiri',
                  ),
                ),
                const SizedBox(height: 16),
                Container(
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
                      Text(
                        'تفاصيل الحجز:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.headlineSmall?.color,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildBookingDetail('الإقامة:', widget.accommodation.title),
                      _buildBookingDetail('تاريخ الوصول:', '${checkIn.day}/${checkIn.month}/${checkIn.year}'),
                      _buildBookingDetail('تاريخ المغادرة:', '${checkOut.day}/${checkOut.month}/${checkOut.year}'),
                      _buildBookingDetail('عدد الليالي:', '$nights ليلة'),
                      _buildBookingDetail('عدد الضيوف:', '$guests ضيف'),
                      const Divider(),
                      _buildBookingDetail('السعر الإجمالي:', '${totalPrice.toStringAsFixed(0)} دج', isTotal: true),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'سيتم التواصل معك قريباً لتأكيد الحجز وترتيب تفاصيل الدفع.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7F8C8D),
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF27AE60),
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'حسناً',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
          ],
        ),
      ),
    );
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);
      
      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            title: const Text(
              'خطأ في الحجز',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFE74C3C),
                fontFamily: 'Amiri',
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error,
                  color: Color(0xFFE74C3C),
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'حدث خطأ أثناء حفظ الحجز: ${e.toString()}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE74C3C),
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'حسناً',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
  
  Widget _buildBookingDetail(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontFamily: 'Tajawal',
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
                color: isTotal ? const Color(0xFF27AE60) : Theme.of(context).textTheme.headlineSmall?.color,
                fontFamily: 'Tajawal',
              ),
            ),
          ),
        ],
      ),
    );
  }
}