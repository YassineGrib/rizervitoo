import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';

class BookingCancellationDialog extends StatefulWidget {
  final Booking booking;
  final VoidCallback? onCancelled;

  const BookingCancellationDialog({
    super.key,
    required this.booking,
    this.onCancelled,
  });

  @override
  State<BookingCancellationDialog> createState() =>
      _BookingCancellationDialogState();
}

class _BookingCancellationDialogState extends State<BookingCancellationDialog> {
  final BookingService _bookingService = BookingService();
  final _reasonController = TextEditingController();
  bool _isLoading = false;
  String? _selectedReason;

  final List<String> _cancellationReasons = [
    'تغيير في الخطط',
    'ظروف طارئة',
    'عدم الرضا عن الخدمة',
    'مشاكل في الدفع',
    'وجدت خيار أفضل',
    'أخرى',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.cancel_outlined,
              color: Colors.red[600],
              size: 28,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'إلغاء الحجز',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBookingInfo(),
              const SizedBox(height: 20),
              _buildCancellationPolicy(),
              const SizedBox(height: 20),
              _buildReasonSelection(),
              if (_selectedReason == 'أخرى') ...[
                const SizedBox(height: 16),
                _buildCustomReason(),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            child: const Text(
              'إلغاء',
              style: TextStyle(
                fontFamily: 'Tajawal',
                color: Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _isLoading || _selectedReason == null
                ? null
                : _confirmCancellation,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'تأكيد الإلغاء',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'معلومات الحجز',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          ...[
            Text(
              'تفاصيل الحجز', // Booking details
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
          ],
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                '${_formatDate(widget.booking.checkInDate)} - ${_formatDate(widget.booking.checkOutDate)}',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.people,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                '${widget.booking.guestsCount} ضيوف',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.attach_money,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                '${widget.booking.totalAmount.toStringAsFixed(0)} ${widget.booking.currency}',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCancellationPolicy() {
    final daysUntilCheckIn = widget.booking.checkInDate.difference(DateTime.now()).inDays;
    final refundPercentage = _calculateRefundPercentage(daysUntilCheckIn);
    final refundAmount = widget.booking.totalAmount * (refundPercentage / 100);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.orange[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'سياسة الإلغاء',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getCancellationPolicyText(daysUntilCheckIn),
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 14,
              color: Colors.orange[800],
            ),
          ),
          if (refundPercentage > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.monetization_on,
                    color: Colors.green[700],
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'المبلغ المسترد: ${refundAmount.toStringAsFixed(0)} ${widget.booking.currency} ($refundPercentage%)',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 14,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.money_off,
                    color: Colors.red[700],
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'لا يوجد استرداد للمبلغ',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 14,
                        color: Colors.red[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReasonSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'سبب الإلغاء',
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ..._cancellationReasons.map((reason) {
          return RadioListTile<String>(
            title: Text(
              reason,
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 14,
              ),
            ),
            value: reason,
            groupValue: _selectedReason,
            onChanged: (value) {
              setState(() {
                _selectedReason = value;
              });
            },
            activeColor: const Color(0xFF2E7D32),
            contentPadding: EdgeInsets.zero,
            dense: true,
          );
        }),
      ],
    );
  }

  Widget _buildCustomReason() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'تفاصيل السبب',
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _reasonController,
          maxLines: 3,
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            hintText: 'اكتب السبب هنا...',
            hintStyle: const TextStyle(fontFamily: 'Tajawal'),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF2E7D32)),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
          style: const TextStyle(fontFamily: 'Tajawal'),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  int _calculateRefundPercentage(int daysUntilCheckIn) {
    if (daysUntilCheckIn >= 7) {
      return 100; // Full refund if cancelled 7+ days before
    } else if (daysUntilCheckIn >= 3) {
      return 50; // 50% refund if cancelled 3-6 days before
    } else if (daysUntilCheckIn >= 1) {
      return 25; // 25% refund if cancelled 1-2 days before
    } else {
      return 0; // No refund if cancelled on the same day or after check-in
    }
  }

  String _getCancellationPolicyText(int daysUntilCheckIn) {
    if (daysUntilCheckIn >= 7) {
      return 'يمكنك إلغاء الحجز مجاناً واسترداد كامل المبلغ لأن تاريخ الوصول بعد أكثر من 7 أيام.';
    } else if (daysUntilCheckIn >= 3) {
      return 'سيتم استرداد 50% من المبلغ لأن تاريخ الوصول خلال 3-6 أيام.';
    } else if (daysUntilCheckIn >= 1) {
      return 'سيتم استرداد 25% من المبلغ لأن تاريخ الوصول خلال 1-2 يوم.';
    } else {
      return 'لا يمكن استرداد أي مبلغ لأن تاريخ الوصول اليوم أو قد مضى.';
    }
  }

  Future<void> _confirmCancellation() async {
    if (_selectedReason == null) return;

    final reason = _selectedReason == 'أخرى'
        ? _reasonController.text.trim()
        : _selectedReason!;

    if (_selectedReason == 'أخرى' && reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'يرجى كتابة سبب الإلغاء',
            style: TextStyle(fontFamily: 'Tajawal'),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _bookingService.cancelBooking(
        widget.booking.id,
        reason,
      );

      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم إلغاء الحجز بنجاح',
            style: TextStyle(fontFamily: 'Tajawal'),
          ),
          backgroundColor: Colors.green,
        ),
      );

      widget.onCancelled?.call();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'فشل في إلغاء الحجز: $e',
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

  static Future<void> show({
    required BuildContext context,
    required Booking booking,
    VoidCallback? onCancelled,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => BookingCancellationDialog(
        booking: booking,
        onCancelled: onCancelled,
      ),
    );
  }
}