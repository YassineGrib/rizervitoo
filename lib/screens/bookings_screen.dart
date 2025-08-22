import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';
import '../constants/app_styles.dart';
import 'modify_booking_screen.dart';
import '../widgets/booking_cancellation_dialog.dart';
import '../widgets/booking_status_manager.dart';
import 'package:intl/intl.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen>
    with SingleTickerProviderStateMixin {
  final BookingService _bookingService = BookingService();
  late TabController _tabController;
  List<Booking> _userBookings = [];
  List<Booking> _hostBookings = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userBookings = await _bookingService.getUserBookings();
      final hostBookings = await _bookingService.getHostBookings();

      setState(() {
        _userBookings = userBookings;
        _hostBookings = hostBookings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[50],
        body: Column(
          children: [
            // Custom header with title and tabs
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
                //   bottomLeft: Radius.circular(24),
                //   bottomRight: Radius.circular(24),
                // ),
              ),
              child: Column(
                children: [
                  // Header with back button and title
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          'الحجوزات',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // Balance the back button
                    ],
                  ),
                  // Tab bar
                  TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    labelStyle: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w600,
                    ),
                    tabs: const [
                      Tab(
                        // icon: Icon(Icons.person),
                        text: 'حجوزاتي',
                      ),
                      Tab(
                        // icon: Icon(Icons.home),
                        text: 'استضافاتي',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Content
             Expanded(
               child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF2E7D32),
                ),
              )
            : _error != null
                ? _buildErrorWidget()
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildUserBookingsTab(),
                      _buildHostBookingsTab(),
                    ],
                  ),
            ),
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
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 16,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadBookings,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
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

  Widget _buildUserBookingsTab() {
    if (_userBookings.isEmpty) {
      return _buildEmptyState(
        icon: Icons.calendar_today,
        title: 'لا توجد حجوزات',
        subtitle: 'لم تقم بأي حجوزات بعد',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      color: const Color(0xFF2E7D32),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _userBookings.length,
        itemBuilder: (context, index) {
          final booking = _userBookings[index];
          return _buildBookingCard(booking, isHost: false);
        },
      ),
    );
  }

  Widget _buildHostBookingsTab() {
    if (_hostBookings.isEmpty) {
      return _buildEmptyState(
        icon: Icons.home,
        title: 'لا توجد حجوزات استضافة',
        subtitle: 'لم يتم حجز أي من إقاماتك بعد',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      color: const Color(0xFF2E7D32),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _hostBookings.length,
        itemBuilder: (context, index) {
          final booking = _hostBookings[index];
          return _buildBookingCard(booking, isHost: true);
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

  Widget _buildBookingCard(Booking booking, {required bool isHost}) {
    final dateFormat = DateFormat('dd/MM/yyyy', 'ar');
    final totalNights = booking.checkOutDate.difference(booking.checkInDate).inDays;
    final guestsCount = booking.guestsCount;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showBookingDetails(booking, isHost),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.accommodationTitle ?? 'إقامة غير محددة',
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
                              booking.accommodationCity ?? '',
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(booking.status),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.calendar_today,
                      label: 'تاريخ الوصول',
                      value: dateFormat.format(booking.checkInDate),
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.calendar_today,
                      label: 'تاريخ المغادرة',
                      value: dateFormat.format(booking.checkOutDate),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.people,
                      label: 'عدد الضيوف',
                      value: '$guestsCount',
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.nights_stay,
                      label: 'عدد الليالي',
                      value: '$totalNights',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'المبلغ الإجمالي',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '${booking.totalAmount.toStringAsFixed(0)} ${booking.currency}',
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (isHost)
                BookingStatusManager(
                  booking: booking,
                  onStatusChanged: () => _loadBookings(),
                )
              else
                Row(
                  children: [
                    if (booking.status == BookingStatus.pending ||
                        booking.status == BookingStatus.confirmed)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _modifyBooking(booking),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text(
                            'تعديل الحجز',
                            style: TextStyle(fontFamily: 'Tajawal'),
                          ),
                        ),
                      ),
                    if (booking.status == BookingStatus.pending ||
                        booking.status == BookingStatus.confirmed)
                      const SizedBox(width: 8),
                    if (booking.status != BookingStatus.cancelled &&
                        booking.status != BookingStatus.completed)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _cancelBooking(booking),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text(
                            'إلغاء الحجز',
                            style: TextStyle(fontFamily: 'Tajawal'),
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BookingStatus status) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case BookingStatus.pending:
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        break;
      case BookingStatus.confirmed:
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        break;
      case BookingStatus.cancelled:
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        break;
      case BookingStatus.completed:
        backgroundColor = Colors.teal[100]!;
        textColor = Colors.teal[800]!;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.arabicLabel,
        style: TextStyle(
          fontFamily: 'Tajawal',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showBookingDetails(Booking booking, bool isHost) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BookingDetailsSheet(
        booking: booking,
        isHost: isHost,
        onBookingUpdated: _loadBookings,
      ),
    );
  }

  void _modifyBooking(Booking booking) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ModifyBookingScreen(booking: booking),
      ),
    ).then((_) => _loadBookings());
  }

  void _cancelBooking(Booking booking) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => BookingCancellationDialog(booking: booking),
    );

    if (result != null) {
      try {
        await _bookingService.cancelBooking(
          booking.id,
          result['reason'] as String,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تم إلغاء الحجز بنجاح',
              style: TextStyle(fontFamily: 'Tajawal'),
            ),
            backgroundColor: Colors.green,
          ),
        );
        _loadBookings();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'فشل في إلغاء الحجز: $e',
              style: const TextStyle(fontFamily: 'Tajawal'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class BookingDetailsSheet extends StatelessWidget {
  final Booking booking;
  final bool isHost;
  final VoidCallback onBookingUpdated;

  const BookingDetailsSheet({
    super.key,
    required this.booking,
    required this.isHost,
    required this.onBookingUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy', 'ar');
    final totalNights = booking.checkOutDate.difference(booking.checkInDate).inDays;
    final guestsCount = booking.guestsCount;

    return Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'تفاصيل الحجز',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(booking.status),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            booking.status.arabicLabel,
                            style: const TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildDetailItem('معرف الحجز', booking.id),
                    _buildDetailItem('الإقامة', booking.accommodationTitle ?? 'غير محدد'),
                    _buildDetailItem('الموقع', booking.accommodationCity ?? 'غير محدد'),
                    _buildDetailItem('تاريخ الوصول', dateFormat.format(booking.checkInDate)),
                    _buildDetailItem('تاريخ المغادرة', dateFormat.format(booking.checkOutDate)),
                    _buildDetailItem('عدد الليالي', '$totalNights'),
                    _buildDetailItem('عدد الضيوف', '${booking.guestsCount}'),
                    _buildDetailItem('إجمالي الضيوف', '$guestsCount'),
                    const Divider(height: 32),
                    _buildPriceBredown(),
                    if (booking.specialRequests != null) ...[
                      const Divider(height: 32),
                      _buildDetailItem('طلبات خاصة', booking.specialRequests!),
                    ],
                    if (booking.guestNotes != null) ...[
                      const Divider(height: 32),
                      _buildDetailItem('ملاحظات الضيف', booking.guestNotes!),
                    ],
                    if (booking.hostNotes != null) ...[
                      const Divider(height: 32),
                      _buildDetailItem('ملاحظات المضيف', booking.hostNotes!),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBredown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'تفاصيل السعر',
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildPriceItem('السعر الأساسي', booking.totalAmount),
        const Divider(),
        _buildPriceItem(
          'الإجمالي',
          booking.totalAmount,
          isTotal: true,
        ),
      ],
    );
  }

  Widget _buildPriceItem(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.black : Colors.grey[700],
            ),
          ),
          Text(
            '${amount.toStringAsFixed(0)} ${booking.currency}',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? const Color(0xFF2E7D32) : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.green;
      case BookingStatus.completed:
        return Colors.teal;
      case BookingStatus.cancelled:
        return Colors.red;
    }
  }
}