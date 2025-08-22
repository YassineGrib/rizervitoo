import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rizervitoo/screens/welcome_screen.dart';
import 'package:rizervitoo/screens/profile_screen.dart';
import 'package:rizervitoo/screens/travel_guides_screen.dart';
import 'package:rizervitoo/screens/accommodations_screen.dart';
import 'package:rizervitoo/screens/bookings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

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
        return _buildSearchContent();
      case 2:
        return const BookingsScreen();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildSearchContent() {
    return const Center(
      child: Text(
        'البحث قيد التطوير',
        style: TextStyle(
          fontFamily: 'Tajawal',
          fontSize: 18,
          color: Colors.grey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset(
              'assest/images/logo_blue.png',
              height: 32,
            ),
            const SizedBox(width: 12),
            const Text(
              'ريزرفيتو',
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue.shade600,
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Tajawal',
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Tajawal',
        ),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'البحث',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'الحجوزات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'الملف الشخصي',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Message
          Container(
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
            ),
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
                const SizedBox(height: 8),
                Text(
                  'اكتشف أجمل الوجهات السياحية في الجزائر',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          
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
          
          // Quick Action Cards - 3 in a row
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.hotel,
                  title: 'الإقامات',
                  subtitle: 'احجز إقامتك',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AccommodationsScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.home,
                  title: 'المنازل',
                  subtitle: 'استأجر منزل',
                  color: Colors.green,
                  onTap: () {
                    // TODO: Navigate to houses
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.bed,
                  title: 'المراقد',
                  subtitle: 'احجز مرقدك',
                  color: Colors.purple,
                  onTap: () {
                    // TODO: Navigate to beds
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Travel Guide Card - Full Width
          _buildTravelGuideCard(),
          
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
          Container(
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
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
}