import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rizervitoo/screens/welcome_screen.dart';
import 'package:rizervitoo/screens/profile_screen.dart';
import 'package:rizervitoo/screens/travel_guides_screen.dart';
import 'package:rizervitoo/screens/accommodations_screen.dart';
import 'package:rizervitoo/screens/bookings_screen.dart';
import 'package:rizervitoo/screens/my_accommodations_screen.dart';
import 'package:rizervitoo/screens/travel_agencies/travel_agencies_screen.dart';
import 'package:rizervitoo/services/booking_service.dart';
import 'package:rizervitoo/models/booking.dart';
import 'package:rizervitoo/constants/app_styles.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  final BookingService _bookingService = BookingService();
  List<Booking> _recentBookings = [];
  bool _isLoadingBookings = true;
  
  // Animation controllers
  late AnimationController _taglineController;
  late Animation<double> _taglineAnimation;
  
  // Taglines list
  final List<String> _taglines = [
    'اكتشف أجمل الوجهات السياحية في الجزائر',
    'احجز إقامتك المثالية بسهولة وأمان',
    'استمتع بتجربة سفر لا تُنسى',
    'اكتشف كنوز الجزائر الخفية',
    'رحلتك تبدأ من هنا',
  ];
  int _currentTaglineIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadRecentBookings();
    
    // Initialize animation controller
    _taglineController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _taglineAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _taglineController,
      curve: Curves.easeInOut,
    ));
    
    // Start the animation and tagline rotation
    _startTaglineRotation();
  }
  
  void _startTaglineRotation() {
    _taglineController.forward();
    
    // Change tagline every 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _taglineController.reverse().then((_) {
          if (mounted) {
            setState(() {
              _currentTaglineIndex = (_currentTaglineIndex + 1) % _taglines.length;
            });
            _startTaglineRotation();
          }
        });
      }
    });
  }
  
  @override
  void dispose() {
    _taglineController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentBookings() async {
    try {
      final bookings = await _bookingService.getUserBookings();
      setState(() {
        _recentBookings = bookings.take(3).toList(); // Show only 3 recent bookings
        _isLoadingBookings = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingBookings = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          (route) => false,
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تسجيل الخروج: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onItemTapped(int index) {
    if (index == 3) {
      // Navigate to profile screen
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return _buildMyAccommodationsContent();
      case 2:
        return const BookingsScreen();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildMyAccommodationsContent() {
    return const MyAccommodationsScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (_selectedIndex == 1 || _selectedIndex == 2) ? null : AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            GestureDetector(
              onLongPress: () {
                // Hidden admin access - long press on logo
                Navigator.pushNamed(context, '/admin-login');
              },
              child: Image.asset(
                'assest/images/logo_blue.png',
                height: 32,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'ريزرفيتو',
              style: AppStyles.appBarTitleStyle.copyWith(
                color: Colors.blue,
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  // TODO: Handle notifications
                },
                icon: Icon(
                  Icons.notifications_outlined,
                  color: Colors.grey.shade700,
                  size: 24,
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: _logout,
            icon: Icon(
              Icons.logout,
              color: Colors.red.shade600,
              size: 24,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _getSelectedScreen(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            selectedItemColor: AppStyles.primaryColor,
            unselectedItemColor: Colors.grey.shade500,
            selectedLabelStyle: AppStyles.buttonTextStyle.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            unselectedLabelStyle: AppStyles.buttonTextStyle.copyWith(
              fontSize: 11,
            ),
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.home_outlined, Icons.home, 0),
                label: 'الرئيسية',
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.home_work_outlined, Icons.home_work, 1),
                label: 'استضافاتي',
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.bookmark_border, Icons.bookmark, 2),
                label: 'الحجوزات',
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.person_outline, Icons.person, 3),
                label: 'الملف الشخصي',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData unselectedIcon, IconData selectedIcon, int index) {
    final isSelected = _selectedIndex == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected ? AppStyles.primaryColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        isSelected ? selectedIcon : unselectedIcon,
        size: 24,
      ),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Message with Animation
          _buildAnimatedWelcomeCard(),
          
          const SizedBox(height: 24),
          
          // Quick Actions Title
          Text(
            'الخدمات السريعة',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Unified Accommodation Card
          _buildUnifiedAccommodationCard(),
          
          const SizedBox(height: 16),
          
          // Travel Guide Card - Full Width
          _buildTravelGuideCard(),
          
          const SizedBox(height: 16),
          
          // Travel Agencies Card - Full Width
          _buildTravelAgenciesCard(),
          
          const SizedBox(height: 24),
          
          // Recent Bookings Section
          Text(
            'الحجوزات الأخيرة',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Recent Bookings List
          _buildRecentBookingsList(),
        ],
      ),
    );
  }

  Widget _buildRecentBookingsList() {
    if (_isLoadingBookings) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_recentBookings.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.bookmark_border,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'لا توجد حجوزات حتى الآن',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ابدأ بحجز إقامتك الأولى',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _recentBookings.map((booking) => _buildRecentBookingCard(booking)).toList(),
    );
  }

  Widget _buildRecentBookingCard(Booking booking) {
    final dateFormat = DateFormat('dd/MM/yyyy', 'ar');
    final totalNights = booking.checkOutDate.difference(booking.checkInDate).inDays;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _getStatusColor(booking.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getStatusIcon(booking.status),
              color: _getStatusColor(booking.status),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.accommodationTitle ?? 'إقامة غير محددة',
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${dateFormat.format(booking.checkInDate)} - ${dateFormat.format(booking.checkOutDate)}',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      _getStatusText(booking.status),
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 12,
                        color: _getStatusColor(booking.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${booking.totalAmount.toStringAsFixed(0)} ${booking.currency}',
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
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

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.blue;
      case BookingStatus.completed:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Icons.schedule;
      case BookingStatus.confirmed:
        return Icons.check_circle;
      case BookingStatus.completed:
        return Icons.task_alt;
      case BookingStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'في الانتظار';
      case BookingStatus.confirmed:
        return 'مؤكد';
      case BookingStatus.completed:
        return 'مكتمل';
      case BookingStatus.cancelled:
        return 'ملغي';
    }
  }

  Widget _buildAnimatedWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Colors.blue.shade600,
            Colors.blue.shade800,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'مرحباً بك في ريزرفيتو',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    AnimatedBuilder(
                      animation: _taglineAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _taglineAnimation.value,
                          child: Transform.translate(
                            offset: Offset(0, (1 - _taglineAnimation.value) * 20),
                            child: Text(
                              _taglines[_currentTaglineIndex],
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                                height: 1.4,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
           
              // Container(
              //   width: 60,
              //   height: 60,
              //   decoration: BoxDecoration(
              //     color: Colors.white.withOpacity(0.2),
              //     borderRadius: BorderRadius.circular(16),
              //   ),
              //   child: const Icon(
              //     Icons.waving_hand,
              //     color: Colors.white,
              //     size: 32,
              //   ),
              // ),
            ],
          ),
          // const SizedBox(height: 16),
         
          // Row(
          //   children: [
          //     Container(
          //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          //       decoration: BoxDecoration(
          //         color: Colors.white.withOpacity(0.2),
          //         borderRadius: BorderRadius.circular(20),
          //       ),

          //       child: Row(
          //         mainAxisSize: MainAxisSize.min,
          //         children: [
          //           Icon(
          //             Icons.location_on,
          //             color: Colors.white,
          //             size: 16,
          //           ),
          //           const SizedBox(width: 4),
          //           Text(
          //             'الجزائر',
          //             style: TextStyle(
          //               fontFamily: 'Tajawal',
          //               fontSize: 12,
          //               color: Colors.white,
          //               fontWeight: FontWeight.w500,
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //     const SizedBox(width: 8),
          //     Container(
          //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          //       decoration: BoxDecoration(
          //         color: Colors.white.withOpacity(0.2),
          //         borderRadius: BorderRadius.circular(20),
          //       ),
          //       child: Row(
          //         mainAxisSize: MainAxisSize.min,
          //         children: [
          //           Icon(
          //             Icons.star,
          //             color: Colors.white,
          //             size: 16,
          //           ),
          //           const SizedBox(width: 4),
          //           Text(
          //             'أفضل الأسعار',
          //             style: TextStyle(
          //               fontFamily: 'Tajawal',
          //               fontSize: 12,
          //               color: Colors.white,
          //               fontWeight: FontWeight.w500,
          //             ),
          //           ),
          //         ],
          //       ),
              
            
          
        ],
      ),
    );
  }

  Widget _buildUnifiedAccommodationCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AccommodationsScreen(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade600,
              Colors.blue.shade800,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.home_work,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'جميع أنواع الإقامة',
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'اكتشف وأحجز من مجموعة متنوعة من الخيارات',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildAccommodationType(
                    icon: Icons.hotel,
                    title: 'الفنادق',
                    subtitle: 'إقامة فاخرة',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAccommodationType(
                    icon: Icons.home,
                    title: 'المنازل',
                    subtitle: 'خصوصية تامة',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAccommodationType(
                    icon: Icons.bed,
                    title: 'المراقد',
                    subtitle: 'أسعار مناسبة',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccommodationType({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 10,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTravelGuideCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TravelGuidesScreen(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.shade600,
              Colors.green.shade800,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'دليل السفر',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'اكتشف أفضل الأماكن والمعالم السياحية',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.map,
              color: Colors.white,
              size: 48,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTravelAgenciesCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TravelAgenciesScreen(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.orange.shade600,
              Colors.orange.shade800,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'دليل الوكالات السياحية',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'اكتشف أفضل الوكالات السياحية والعروض المميزة',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.business,
              color: Colors.white,
              size: 48,
            ),
          ],
        ),
      ),
    );
  }
}