import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';
import '../models/accommodation.dart';
import '../services/booking_service.dart';

class CreateBookingScreen extends StatefulWidget {
  final Accommodation accommodation;

  const CreateBookingScreen({
    super.key,
    required this.accommodation,
  });

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  final BookingService _bookingService = BookingService();
  final _formKey = GlobalKey<FormState>();
  final _specialRequestsController = TextEditingController();
  final _guestNotesController = TextEditingController();

  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _guestsCount = 1;
  bool _isLoading = false;
  bool _isCheckingAvailability = false;
  bool _isAvailable = false;

  @override
  void dispose() {
    _specialRequestsController.dispose();
    _guestNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            'حجز جديد',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFF2E7D32),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAccommodationCard(),
                      const SizedBox(height: 24),
                      _buildDateSelection(),
                      const SizedBox(height: 24),
                      _buildGuestSelection(),
                      const SizedBox(height: 24),
                      _buildSpecialRequests(),
                      const SizedBox(height: 24),
                      _buildGuestNotes(),
                      if (_checkInDate != null && _checkOutDate != null) ...[
                        const SizedBox(height: 24),
                        _buildPricingSummary(),
                      ],
                    ],
                  ),
                ),
              ),
              _buildBottomBar(),
            ],
          ),
        ),
    );
  }

  Widget _buildAccommodationCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: widget.accommodation.images.isNotEmpty
                  ? Image.network(
                      widget.accommodation.images.first,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, color: Colors.grey),
                        );
                      },
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.accommodation.title,
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.accommodation.city,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.accommodation.pricePerNight.toStringAsFixed(0)} ${widget.accommodation.currency} / ليلة',
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelection() {
    final dateFormat = DateFormat('dd/MM/yyyy', 'ar');
    
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
            const Text(
              'تواريخ الإقامة',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectCheckInDate(),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تاريخ الوصول',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _checkInDate != null
                                ? dateFormat.format(_checkInDate!)
                                : 'اختر التاريخ',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 16,
                              color: _checkInDate != null
                                  ? Colors.black
                                  : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _checkInDate != null ? () => _selectCheckOutDate() : null,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _checkInDate != null
                              ? Colors.grey[300]!
                              : Colors.grey[200]!,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تاريخ المغادرة',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 12,
                              color: _checkInDate != null
                                  ? Colors.grey[600]
                                  : Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _checkOutDate != null
                                ? dateFormat.format(_checkOutDate!)
                                : 'اختر التاريخ',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 16,
                              color: _checkOutDate != null
                                  ? Colors.black
                                  : Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_checkInDate != null && _checkOutDate != null) ...[
              const SizedBox(height: 16),
              _buildAvailabilityStatus(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityStatus() {
    if (_isCheckingAvailability) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.blue,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'جاري التحقق من التوفر...',
              style: TextStyle(
                fontFamily: 'Tajawal',
                color: Colors.blue,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isAvailable ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            _isAvailable ? Icons.check_circle : Icons.cancel,
            color: _isAvailable ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            _isAvailable ? 'متاح للحجز' : 'غير متاح في هذه التواريخ',
            style: TextStyle(
              fontFamily: 'Tajawal',
              color: _isAvailable ? Colors.green[700] : Colors.red[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestSelection() {
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
            const Text(
              'عدد الضيوف',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الضيوف',
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: _guestsCount > 1
                          ? () => setState(() => _guestsCount--)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                      color: const Color(0xFF2E7D32),
                    ),
                    Container(
                      width: 40,
                      alignment: Alignment.center,
                      child: Text(
                        '$_guestsCount',
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _guestsCount < widget.accommodation.maxGuests
                          ? () => setState(() => _guestsCount++)
                          : null,
                      icon: const Icon(Icons.add_circle_outline),
                      color: const Color(0xFF2E7D32),
                    ),
                  ],
                ),
              ],
            ),
            Text(
              'الحد الأقصى: ${widget.accommodation.maxGuests} ضيوف',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialRequests() {
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
            const Text(
              'طلبات خاصة (اختياري)',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _specialRequestsController,
              maxLines: 3,

              decoration: InputDecoration(
                hintText: 'أي طلبات خاصة للمضيف...',
                hintStyle: const TextStyle(fontFamily: 'Tajawal'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF2E7D32)),
                ),
              ),
              style: const TextStyle(fontFamily: 'Tajawal'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestNotes() {
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
            const Text(
              'ملاحظات إضافية (اختياري)',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _guestNotesController,
              maxLines: 3,

              decoration: InputDecoration(
                hintText: 'أي ملاحظات أو معلومات إضافية...',
                hintStyle: const TextStyle(fontFamily: 'Tajawal'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF2E7D32)),
                ),
              ),
              style: const TextStyle(fontFamily: 'Tajawal'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingSummary() {
    if (_checkInDate == null || _checkOutDate == null) return const SizedBox();

    final nights = _checkOutDate!.difference(_checkInDate!).inDays;
    final totalAmount = widget.accommodation.pricePerNight * nights;

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
            const Text(
              'ملخص التكلفة',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.accommodation.pricePerNight.toStringAsFixed(0)} ${widget.accommodation.currency} × $nights ليلة',
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${totalAmount.toStringAsFixed(0)} ${widget.accommodation.currency}',
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'المجموع',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${totalAmount.toStringAsFixed(0)} ${widget.accommodation.currency}',
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final canBook = _checkInDate != null &&
        _checkOutDate != null &&
        _isAvailable &&
        !_isCheckingAvailability;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canBook && !_isLoading ? _createBooking : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'تأكيد الحجز',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectCheckInDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('ar'),
    );

    if (date != null) {
      setState(() {
        _checkInDate = date;
        if (_checkOutDate != null && _checkOutDate!.isBefore(date)) {
          _checkOutDate = null;
        }
      });
    }
  }

  Future<void> _selectCheckOutDate() async {
    if (_checkInDate == null) return;

    final date = await showDatePicker(
      context: context,
      initialDate: _checkInDate!.add(const Duration(days: 1)),
      firstDate: _checkInDate!.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('ar'),
    );

    if (date != null) {
      setState(() {
        _checkOutDate = date;
      });
      _checkAvailability();
    }
  }

  Future<void> _checkAvailability() async {
    if (_checkInDate == null || _checkOutDate == null) return;

    setState(() {
      _isCheckingAvailability = true;
    });

    try {
      final isAvailable = await _bookingService.checkAvailability(
        widget.accommodation.id,
        _checkInDate!,
        _checkOutDate!,
      );

      setState(() {
        _isAvailable = isAvailable;
        _isCheckingAvailability = false;
      });
    } catch (e) {
      setState(() {
        _isAvailable = false;
        _isCheckingAvailability = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'فشل في التحقق من التوفر: $e',
            style: const TextStyle(fontFamily: 'Tajawal'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _createBooking() async {
    if (!_formKey.currentState!.validate() ||
        _checkInDate == null ||
        _checkOutDate == null ||
        !_isAvailable) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final request = BookingRequest(
        accommodationId: widget.accommodation.id,
        checkInDate: _checkInDate!,
        checkOutDate: _checkOutDate!,
        guestsCount: _guestsCount,
        pricePerNight: widget.accommodation.pricePerNight,
        specialRequests: _specialRequestsController.text.trim().isEmpty
            ? null
            : _specialRequestsController.text.trim(),
        guestNotes: _guestNotesController.text.trim().isEmpty
            ? null
            : _guestNotesController.text.trim(),
      );

      await _bookingService.createBooking(request);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم إنشاء الحجز بنجاح!',
            style: TextStyle(fontFamily: 'Tajawal'),
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop(true); // Return true to indicate success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'فشل في إنشاء الحجز: $e',
            style: const TextStyle(fontFamily: 'Tajawal'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}