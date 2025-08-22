import 'package:flutter/material.dart';
import '../models/travel_guide.dart';
import '../services/travel_guide_service.dart';
import '../constants/app_styles.dart';
import 'travel_guide_detail_screen.dart';

class TravelGuidesScreen extends StatefulWidget {
  const TravelGuidesScreen({super.key});

  @override
  State<TravelGuidesScreen> createState() => _TravelGuidesScreenState();
}

class _TravelGuidesScreenState extends State<TravelGuidesScreen>
    with SingleTickerProviderStateMixin {
  final TravelGuideService _travelGuideService = TravelGuideService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<TravelGuide> _travelGuides = [];
  List<TravelGuide> _featuredGuides = [];
  List<String> _categories = [];
  String? _selectedCategory;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _currentPage = 0;
  final int _pageSize = 10;

  late TabController _tabController;
  final List<String> _tabs = ['الكل', 'مميز', 'حديث'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadInitialData();
    _scrollController.addListener(_onScroll);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMoreData) {
      _loadMoreData();
    }
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      _loadDataForTab(_tabController.index);
    }
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final futures = await Future.wait([
        _travelGuideService.getAllTravelGuides(limit: _pageSize),
        _travelGuideService.getFeaturedTravelGuides(),
        _travelGuideService.getCategories(),
      ]);

      setState(() {
        _travelGuides = futures[0] as List<TravelGuide>;
        _featuredGuides = futures[1] as List<TravelGuide>;
        _categories = futures[2] as List<String>;
        _hasMoreData = _travelGuides.length == _pageSize;
        _currentPage = 0;
      });
    } catch (e) {
      _showErrorSnackBar('خطأ في تحميل الأدلة السياحية: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadDataForTab(int tabIndex) async {
    setState(() {
      _isLoading = true;
      _currentPage = 0;
      _hasMoreData = true;
    });

    try {
      List<TravelGuide> guides;
      switch (tabIndex) {
        case 0: // الكل
          if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
            guides = await _travelGuideService.getTravelGuidesByCategory(
              _selectedCategory!,
              limit: _pageSize,
            );
          } else {
            guides = await _travelGuideService.getAllTravelGuides(
              limit: _pageSize,
            );
          }
          break;
        case 1: // مميز
          guides = await _travelGuideService.getFeaturedTravelGuides(
            limit: _pageSize,
          );
          break;
        case 2: // حديث
          guides = await _travelGuideService.getRecentTravelGuides(
            limit: _pageSize,
          );
          break;
        default:
          guides = [];
      }

      setState(() {
        _travelGuides = guides;
        _hasMoreData = guides.length == _pageSize;
      });
    } catch (e) {
      _showErrorSnackBar('خطأ في تحميل البيانات: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreData() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      List<TravelGuide> newGuides;
      if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
        newGuides = await _travelGuideService.getTravelGuidesByCategory(
          _selectedCategory!,
          limit: _pageSize,
        );
      } else {
        newGuides = await _travelGuideService.getAllTravelGuides(
          limit: _pageSize,
        );
      }
      
      // Filter out already loaded guides to simulate pagination
      final existingIds = _travelGuides.map((g) => g.id).toSet();
      newGuides = newGuides.where((g) => !existingIds.contains(g.id)).toList();

      setState(() {
        _travelGuides.addAll(newGuides);
        _currentPage++;
        _hasMoreData = newGuides.length == _pageSize;
      });
    } catch (e) {
      _showErrorSnackBar('خطأ في تحميل المزيد من البيانات: $e');
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _searchTravelGuides(String query) async {
    if (query.isEmpty) {
      _loadDataForTab(_tabController.index);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      List<TravelGuide> guides;
      if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
        // Search within specific category
        final allGuides = await _travelGuideService.searchTravelGuides(query);
        guides = allGuides.where((guide) => guide.category == _selectedCategory).toList();
      } else {
        // Search all guides
        guides = await _travelGuideService.searchTravelGuides(query);
      }

      setState(() {
        _travelGuides = guides;
        _hasMoreData = false;
      });
    } catch (e) {
      _showErrorSnackBar('خطأ في البحث: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Tajawal'),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            'الأدلة السياحية',
            style: AppStyles.appBarTitleStyle,
          ),
          backgroundColor: AppStyles.primaryColor,
          elevation: 0,
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: AppStyles.buttonTextStyle.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: AppStyles.buttonTextStyle.copyWith(
              color: Colors.white70,
              fontSize: 14,
            ),
            tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
          ),
        ),
      body: Column(
        children: [
          // Search and Filter Section - Commented out for now
          /*
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF2E7D32),
                  const Color(0xFF388E3C),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E7D32).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: 'ابحث عن وجهة أو مكان...',
                      hintStyle: TextStyle(
                        fontFamily: 'Tajawal',
                        color: Colors.grey[500],
                      ),
                      suffixIcon: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.search, color: Colors.white, size: 20),
                          onPressed: () => _searchTravelGuides(_searchController.text),
                        ),
                      ),
                      prefixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                _loadDataForTab(_tabController.index);
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 18,
                      ),
                    ),
                    onSubmitted: _searchTravelGuides,
                  ),
                ),
                const SizedBox(height: 12),
                // Category Filter
                if (_categories.isNotEmpty)
                  Container(
                    height: 50,
                    margin: const EdgeInsets.only(top: 4),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      itemCount: _categories.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _buildCategoryChip('الكل', null);
                        }
                        final category = _categories[index - 1];
                        return _buildCategoryChip(
                          TravelGuide(
                            id: '',
                            title: '',
                            description: '',
                            content: '',
                            category: category,
                            tags: [],
                            location: '',
                            isPublished: true,
                            viewCount: 0,
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now(),
                          ).categoryDisplayName,
                          category,
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          */
          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF2E7D32),
                    ),
                  )
                : _travelGuides.isEmpty
                    ? _buildEmptyState()
                    : _buildTravelGuidesList(),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, String? category) {
    final isSelected = _selectedCategory == category;
    return Container(
      margin: const EdgeInsets.only(left: 12),
      child: Material(
        elevation: isSelected ? 8 : 4,
        borderRadius: BorderRadius.circular(25),
        shadowColor: isSelected ? const Color(0xFF2E7D32).withOpacity(0.4) : Colors.black.withOpacity(0.1),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedCategory = isSelected ? null : category;
            });
            _loadDataForTab(_tabController.index);
          },
          borderRadius: BorderRadius.circular(25),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFF2E7D32), Color(0xFF388E3C)],
                    )
                  : null,
              color: isSelected ? null : Colors.white.withOpacity(0.9),
              border: Border.all(
                color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Tajawal',
                color: isSelected ? Colors.white : const Color(0xFF2E7D32),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.explore_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد أدلة سياحية متاحة',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'جرب البحث بكلمات مختلفة أو تغيير الفئة',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTravelGuidesList() {
    return RefreshIndicator(
      onRefresh: () => _loadDataForTab(_tabController.index),
      color: const Color(0xFF2E7D32),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _travelGuides.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _travelGuides.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(
                  color: Color(0xFF2E7D32),
                ),
              ),
            );
          }

          final guide = _travelGuides[index];
          return _buildTravelGuideCard(guide);
        },
      ),
    );
  }

  Widget _buildTravelGuideCard(TravelGuide guide) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TravelGuideDetailScreen(guide: guide),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF2E7D32).withOpacity(0.1),
                      const Color(0xFF2E7D32).withOpacity(0.3),
                    ],
                  ),
                ),
                child: guide.imageUrl != null
                    ? Stack(
                        children: [
                          Image.network(
                            guide.imageUrl!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholderImage();
                            },
                          ),
                          // Gradient overlay
                          Container(
                            height: 200,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.3),
                                ],
                              ),
                            ),
                          ),
                          // Category badge
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E7D32),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                guide.categoryDisplayName,
                                style: const TextStyle(
                                  fontFamily: 'Tajawal',
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : _buildPlaceholderImage(),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    guide.title,
                    style: AppStyles.sectionTitleStyle.copyWith(
                      color: const Color(0xFF1B5E20),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Location
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Color(0xFF2E7D32),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          guide.location,
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 14,
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Description
                  Text(
                    guide.shortDescription,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Views
                      Row(
                        children: [
                          const Icon(
                            Icons.visibility,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${guide.formattedViewCount} مشاهدة',
                            style: const TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      // Read more
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'اقرأ المزيد',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 12,
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.bold,
                          ),
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
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2E7D32).withOpacity(0.1),
            const Color(0xFF2E7D32).withOpacity(0.3),
          ],
        ),
      ),
      child: const Icon(
        Icons.explore,
        size: 60,
        color: Color(0xFF2E7D32),
      ),
    );
  }
}