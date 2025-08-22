import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';
import '../constants/app_styles.dart';

class ModifyBookingScreen extends StatefulWidget {
  final Booking booking;

  const ModifyBookingScreen({
    super.key,
    required this.booking,
  });

  @override
  State<ModifyBookingScreen> createState() => _ModifyBookingScreenState();
}

class _ModifyBookingScreenState extends State<ModifyBookingScreen> {
  final BookingService _bookingService = BookingService();
  final _formKey = GlobalKey<FormState>();
  final _specialRequestsController = TextEditingController();
  final _guestNotesController = TextEditingController();

  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _guestsCount = 1;
  bool _isLoading = false;
  bool _isCheckingAvailability = false;
  bool _isAvailable = true;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _checkInDate = widget.booking.checkInDate;
    _checkOutDate = widget.booking.checkOutDate;
    _guestsCount = widget.booking.guestsCount;
    _specialRequestsController.text = widget.booking.specialRequests ?? '';
    _guestNotesController.text = widget.booking.guestNotes ?? '';
  }

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
            'تعديل الحجز',
            style: AppStyles.appBarTitleStyle,
          ),
          backgroundColor: AppStyles.primaryColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => _handleBackPress(),
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
                      _buildBookingInfo(),
                      const SizedBox(height: 24),
                      _buildDateModification(),
                      const SizedBox(height: 24),
                      _buildGuestModification(),
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

  Widget _buildBookingInfo() {
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'معلومات الحجز',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(widget.booking.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.booking.status.arabicLabel,
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'رقم الحجز: ${widget.booking.id}',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            ...[
              const SizedBox(height: 8),
              Text(
                widget.booking.accommodationTitle ?? 'تفاصيل الإقامة',
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
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
                    widget.booking.accommodationCity ?? 'المدينة',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 14,
                      color: Colors.grey[600],
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

  Widget _buildDateModification() {
    final dateFormat = DateFormat('dd/MM/yyyy', 'ar');
    final canModifyDates = widget.booking.status == BookingStatus.pending ||
        widget.booking.status == BookingStatus.confirmed;
    
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'تواريخ الإقامة',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!canModifyDates)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'غير قابل للتعديل',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 12,
                        color: Colors.orange[800],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: canModifyDates ? () => _selectCheckInDate() : null,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: canModifyDates
                              ? Colors.grey[300]!
                              : Colors.grey[200]!,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: canModifyDates ? Colors.white : Colors.grey[50],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تاريخ الوصول',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 12,
                              color: canModifyDates
                                  ? Colors.grey[600]
                                  : Colors.grey[400],
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
                              color: canModifyDates
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
                    onTap: canModifyDates && _checkInDate != null
                        ? () => _selectCheckOutDate()
                        : null,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: canModifyDates && _checkInDate != null
                              ? Colors.grey[300]!
                              : Colors.grey[200]!,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: canModifyDates ? Colors.white : Colors.grey[50],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تاريخ المغادرة',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 12,
                              color: canModifyDates && _checkInDate != null
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
                              color: canModifyDates
                                  ? Colors.black
                                  : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_hasDateChanges() && _checkInDate != null && _checkOutDate != null) ...[
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
            _isAvailable ? 'متاح للتعديل' : 'غير متاح في هذه التواريخ',
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

  Widget _buildGuestModification() {
    final canModifyGuests = widget.booking.status == BookingStatus.pending ||
        widget.booking.status == BookingStatus.confirmed;
    final maxGuests = 10; // Default max guests
    
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'عدد الضيوف',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!canModifyGuests)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'غير قابل للتعديل',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 12,
                        color: Colors.orange[800],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الضيوف',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 16,
                    color: canModifyGuests ? Colors.black : Colors.grey[500],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: canModifyGuests && _guestsCount > 1
                          ? () => _updateGuestsCount(_guestsCount - 1)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                      color: canModifyGuests
                          ? const Color(0xFF2E7D32)
                          : Colors.grey[400],
                    ),
                    Container(
                      width: 40,
                      alignment: Alignment.center,
                      child: Text(
                        '$_guestsCount',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: canModifyGuests ? Colors.black : Colors.grey[500],
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: canModifyGuests && _guestsCount < maxGuests
                          ? () => _updateGuestsCount(_guestsCount + 1)
                          : null,
                      icon: const Icon(Icons.add_circle_outline),
                      color: canModifyGuests
                          ? const Color(0xFF2E7D32)
                          : Colors.grey[400],
                    ),
                  ],
                ),
              ],
            ),
            Text(
              'الحد الأقصى: $maxGuests ضيوف',
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
              'طلبات خاصة',
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

              onChanged: (_) => _checkForChanges(),
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
              'ملاحظات إضافية',
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
    
              onChanged: (_) => _checkForChanges(),
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
    final totalAmount = widget.booking.pricePerNight * nights;
    final originalAmount = widget.booking.totalAmount;
    final priceDifference = totalAmount - originalAmount;

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
              'ملخص التكلفة المحدثة',
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
                  '${widget.booking.pricePerNight.toStringAsFixed(0)} ${widget.booking.currency} × $nights ليلة',
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${totalAmount.toStringAsFixed(0)} ${widget.booking.currency}',
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            if (priceDifference != 0) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    priceDifference > 0 ? 'رسوم إضافية' : 'خصم',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 14,
                      color: priceDifference > 0 ? Colors.red : Colors.green,
                    ),
                  ),
                  Text(
                    '${priceDifference > 0 ? '+' : ''}${priceDifference.toStringAsFixed(0)} ${widget.booking.currency}',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 14,
                      color: priceDifference > 0 ? Colors.red : Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'المجموع الجديد',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${totalAmount.toStringAsFixed(0)} ${widget.booking.currency}',
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
    final canSave = _hasChanges &&
        _checkInDate != null &&
        _checkOutDate != null &&
        (_isAvailable || !_hasDateChanges()) &&
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
            onPressed: canSave && !_isLoading ? _saveChanges : null,
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
                    'حفظ التغييرات',
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

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.blue;
      case BookingStatus.completed:
        return Colors.teal;
      case BookingStatus.cancelled:
        return Colors.red;
    }
  }

  bool _hasDateChanges() {
    return _checkInDate != widget.booking.checkInDate ||
        _checkOutDate != widget.booking.checkOutDate;
  }

  void _checkForChanges() {
    final hasChanges = _hasDateChanges() ||
        _guestsCount != widget.booking.guestsCount ||
        _specialRequestsController.text.trim() !=
            (widget.booking.specialRequests ?? '') ||
        _guestNotesController.text.trim() !=
            (widget.booking.guestNotes ?? '');

    if (hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  void _updateGuestsCount(int newCount) {
    setState(() {
      _guestsCount = newCount;
    });
    _checkForChanges();
  }

  Future<void> _selectCheckInDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _checkInDate ?? DateTime.now().add(const Duration(days: 1)),
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
      _checkForChanges();
    }
  }

  Future<void> _selectCheckOutDate() async {
    if (_checkInDate == null) return;

    final date = await showDatePicker(
      context: context,
      initialDate: _checkOutDate ?? _checkInDate!.add(const Duration(days: 1)),
      firstDate: _checkInDate!.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('ar'),
    );

    if (date != null) {
      setState(() {
        _checkOutDate = date;
      });
      _checkForChanges();
      if (_hasDateChanges()) {
        _checkAvailability();
      }
    }
  }

  Future<void> _checkAvailability() async {
    if (_checkInDate == null ||
        _checkOutDate == null) {
      return;
    }

    setState(() {
      _isCheckingAvailability = true;
    });

    try {
      final isAvailable = await _bookingService.checkAvailability(
        widget.booking.accommodationId,
        _checkInDate!,
        _checkOutDate!,
        excludeBookingId: widget.booking.id,
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

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate() ||
        _checkInDate == null ||
        _checkOutDate == null ||
        !_hasChanges) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedBooking = widget.booking.copyWith(
        checkInDate: _checkInDate,
        checkOutDate: _checkOutDate,
        guestsCount: _guestsCount,
        specialRequests: _specialRequestsController.text.trim().isEmpty
            ? null
            : _specialRequestsController.text.trim(),
        guestNotes: _guestNotesController.text.trim().isEmpty
            ? null
            : _guestNotesController.text.trim(),
        totalAmount: _checkInDate != null && _checkOutDate != null
            ? widget.booking.pricePerNight *
                _checkOutDate!.difference(_checkInDate!).inDays
            : widget.booking.totalAmount,
      );

      await _bookingService.updateBooking(
         updatedBooking.id,
         updatedBooking.toJson(),
       );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم حفظ التغييرات بنجاح!',
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
            'فشل في حفظ التغييرات: $e',
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

  Future<void> _handleBackPress() async {
    if (_hasChanges) {
      final shouldDiscard = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
            title: const Text(
              'تجاهل التغييرات؟',
              style: TextStyle(fontFamily: 'Tajawal'),
            ),
            content: const Text(
              'لديك تغييرات غير محفوظة. هل تريد تجاهلها والخروج؟',
              style: TextStyle(fontFamily: 'Tajawal'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'إلغاء',
                  style: TextStyle(fontFamily: 'Tajawal'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: const Text(
                  'تجاهل',
                  style: TextStyle(fontFamily: 'Tajawal'),
                ),
              ),
            ],
          ),
        );

      if (shouldDiscard == true) {
        Navigator.of(context).pop();
      }
    } else {
      Navigator.of(context).pop();
    }
  }
}