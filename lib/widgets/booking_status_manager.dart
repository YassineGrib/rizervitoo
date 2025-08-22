import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';

class BookingStatusManager extends StatefulWidget {
  final Booking booking;
  final VoidCallback? onStatusChanged;

  const BookingStatusManager({
    super.key,
    required this.booking,
    this.onStatusChanged,
  });

  @override
  State<BookingStatusManager> createState() => _BookingStatusManagerState();
}

class _BookingStatusManagerState extends State<BookingStatusManager> {
  final BookingService _bookingService = BookingService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Card(
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
                    'إدارة حالة الحجز',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildCurrentStatus(),
                ],
              ),
              const SizedBox(height: 16),
              _buildStatusActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor(widget.booking.status),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        widget.booking.status.arabicLabel,
        style: const TextStyle(
          fontFamily: 'Tajawal',
          fontSize: 14,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusActions() {
    final actions = _getAvailableActions();
    
    if (actions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'لا توجد إجراءات متاحة لهذا الحجز',
              style: TextStyle(
                fontFamily: 'Tajawal',
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: actions.map((action) => _buildActionButton(action)).toList(),
    );
  }

  Widget _buildActionButton(BookingAction action) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : () => _handleAction(action),
        icon: _isLoading && action == _currentAction
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(action.icon),
        label: Text(
          action.label,
          style: const TextStyle(
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: action.color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  List<BookingAction> _getAvailableActions() {
    final actions = <BookingAction>[];
    final now = DateTime.now();
    final checkInDate = widget.booking.checkInDate;
    final checkOutDate = widget.booking.checkOutDate;

    switch (widget.booking.status) {
      case BookingStatus.pending:
        actions.add(BookingAction(
          type: BookingActionType.confirm,
          label: 'تأكيد الحجز',
          icon: Icons.check_circle,
          color: Colors.green,
          description: 'تأكيد الحجز وإرسال تفاصيل الوصول للضيف',
        ));
        break;

      case BookingStatus.confirmed:
        // Check if it's check-in time (same day or after check-in date)
        if (now.isAfter(checkInDate.subtract(const Duration(days: 1)))) {
          actions.add(BookingAction(
            type: BookingActionType.checkIn,
            label: 'تسجيل الوصول',
            icon: Icons.login,
            color: Colors.blue,
            description: 'تسجيل وصول الضيف إلى المكان',
          ));
        }
        break;

      case BookingStatus.checkedIn:
        // Check if it's check-out time (same day or after check-out date)
        if (now.isAfter(checkOutDate.subtract(const Duration(days: 1)))) {
          actions.add(BookingAction(
            type: BookingActionType.complete,
            label: 'إنهاء الحجز',
            icon: Icons.task_alt,
            color: Colors.teal,
            description: 'إنهاء الحجز وتسجيل مغادرة الضيف',
          ));
        }
        break;

      case BookingStatus.completed:
      case BookingStatus.cancelled:
        // No actions available for completed or cancelled bookings
        break;
    }

    return actions;
  }

  BookingAction? _currentAction;

  Future<void> _handleAction(BookingAction action) async {
    // Show confirmation dialog for important actions
    if (action.type == BookingActionType.confirm ||
        action.type == BookingActionType.complete) {
      final confirmed = await _showConfirmationDialog(action);
      if (!confirmed) return;
    }

    setState(() {
      _isLoading = true;
      _currentAction = action;
    });

    try {
      switch (action.type) {
        case BookingActionType.confirm:
          await _bookingService.confirmBooking(widget.booking.id);
          break;
        case BookingActionType.checkIn:
          await _bookingService.checkInBooking(widget.booking.id);
          break;
        case BookingActionType.complete:
          await _bookingService.completeBooking(widget.booking.id);
          break;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _getSuccessMessage(action.type),
            style: const TextStyle(fontFamily: 'Tajawal'),
          ),
          backgroundColor: Colors.green,
        ),
      );

      widget.onStatusChanged?.call();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'فشل في تنفيذ العملية: $e',
            style: const TextStyle(fontFamily: 'Tajawal'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
        _currentAction = null;
      });
    }
  }

  Future<bool> _showConfirmationDialog(BookingAction action) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                action.icon,
                color: action.color,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  action.label,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                action.description,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              Container(
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
                      'تفاصيل الحجز:',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                        'تفاصيل الحجز',
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 14,
                        ),
                      ),
                    Text(
                      'رقم الحجز: ${widget.booking.id}',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'إلغاء',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: action.color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'تأكيد',
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    ) ?? false;
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.blue;
      case BookingStatus.checkedIn:
        return Colors.green;
      case BookingStatus.completed:
        return Colors.teal;
      case BookingStatus.cancelled:
        return Colors.red;
    }
  }

  String _getSuccessMessage(BookingActionType actionType) {
    switch (actionType) {
      case BookingActionType.confirm:
        return 'تم تأكيد الحجز بنجاح';
      case BookingActionType.checkIn:
        return 'تم تسجيل الوصول بنجاح';
      case BookingActionType.complete:
        return 'تم إنهاء الحجز بنجاح';
    }
  }
}

class BookingAction {
  final BookingActionType type;
  final String label;
  final IconData icon;
  final Color color;
  final String description;

  const BookingAction({
    required this.type,
    required this.label,
    required this.icon,
    required this.color,
    required this.description,
  });
}

enum BookingActionType {
  confirm,
  checkIn,
  complete,
}