import 'package:flutter/material.dart';
import '../models/accommodation.dart';
import '../services/accommodation_service.dart';
import 'accommodation_detail_screen.dart';

class AccommodationsScreen extends StatefulWidget {
  const AccommodationsScreen({super.key});

  @override
  State<AccommodationsScreen> createState() => _AccommodationsScreenState();
}

class _AccommodationsScreenState extends State<AccommodationsScreen> {
  final AccommodationService _accommodationService = AccommodationService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<Accommodation> _accommodations = [];
  List<String> _cities = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 0;
  final int _pageSize = 10;
  
  // Filter variables
  String? _selectedCity;
  String? _selectedType;
  double? _minPrice;
  double? _maxPrice;
  int? _minGuests;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMoreAccommodations();
    }
  }

  Future<void> _loadInitialData() async {
    try {
      final cities = await _accommodationService.getCities();
      final accommodations = await _accommodationService.getAccommodations(
        limit: _pageSize,
        offset: 0,
      );
      
      setState(() {
        _cities = cities;
        _accommodations = accommodations;
        _isLoading = false;
        _hasMore = accommodations.length == _pageSize;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('فشل في تحميل البيانات: $e');
    }
  }

  Future<void> _loadMoreAccommodations() async {
    if (_isLoadingMore || !_hasMore) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    try {
      final newAccommodations = await _accommodationService.getAccommodations(
        city: _selectedCity,
        type: _selectedType,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        minGuests: _minGuests,
        limit: _pageSize,
        offset: (_currentPage + 1) * _pageSize,
      );
      
      setState(() {
        _accommodations.addAll(newAccommodations);
        _currentPage++;
        _isLoadingMore = false;
        _hasMore = newAccommodations.length == _pageSize;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      _showErrorSnackBar('فشل في تحميل المزيد: $e');
    }
  }

  Future<void> _applyFilters() async {
    setState(() {
      _isLoading = true;
      _accommodations.clear();
      _currentPage = 0;
      _hasMore = true;
    });
    
    try {
      final accommodations = await _accommodationService.getAccommodations(
        city: _selectedCity,
        type: _selectedType,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        minGuests: _minGuests,
        limit: _pageSize,
        offset: 0,
      );
      
      setState(() {
        _accommodations = accommodations;
        _isLoading = false;
        _hasMore = accommodations.length == _pageSize;
        _showFilters = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('فشل في تطبيق الفلاتر: $e');
    }
  }

  Future<void> _searchAccommodations(String query) async {
    if (query.isEmpty) {
      _loadInitialData();
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final accommodations = await _accommodationService.searchAccommodations(query);
      setState(() {
        _accommodations = accommodations;
        _isLoading = false;
        _hasMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('فشل في البحث: $e');
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedCity = null;
      _selectedType = null;
      _minPrice = null;
      _maxPrice = null;
      _minGuests = null;
    });
    _applyFilters();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text(
            'الإقامات',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF2C3E50),
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              color: Colors.grey.shade200,
            ),
          ),
        ),
        body: Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: TextField(
                controller: _searchController,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  hintText: 'ابحث عن إقامة...',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF3498DB)),
                  filled: true,
                  fillColor: const Color(0xFFF8F9FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onSubmitted: _searchAccommodations,
              ),
            ),
            
            // Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF3498DB),
                      ),
                    )
                  : _accommodations.isEmpty
                      ? _buildEmptyState()
                      : _buildAccommodationsList(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              _showFilters = !_showFilters;
            });
            if (_showFilters) {
              _showFilterBottomSheet();
            }
          },
          backgroundColor: const Color(0xFF3498DB),
          child: const Icon(Icons.filter_list, color: Colors.white),
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
            Icons.home_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد إقامات متاحة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'جرب تغيير معايير البحث أو الفلاتر',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccommodationsList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _accommodations.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _accommodations.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(
                color: Color(0xFF3498DB),
              ),
            ),
          );
        }
        
        return _buildAccommodationCard(_accommodations[index]);
      },
    );
  }

  Widget _buildAccommodationCard(Accommodation accommodation) {
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
              builder: (context) => AccommodationDetailScreen(
                accommodation: accommodation,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey.shade200,
                child: accommodation.images.isNotEmpty
                    ? Image.network(
                        accommodation.images.first,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildImagePlaceholder();
                        },
                      )
                    : _buildImagePlaceholder(),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Type
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          accommodation.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3498DB).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          accommodation.typeDisplayName,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3498DB),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Location
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Color(0xFF7F8C8D),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${accommodation.city}, ${accommodation.state}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF7F8C8D),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Guest Info
                  Text(
                    accommodation.guestInfo,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7F8C8D),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Rating and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: Color(0xFFF39C12),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            accommodation.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${accommodation.totalReviews})',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF7F8C8D),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            accommodation.formattedPrice,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF27AE60),
                            ),
                          ),
                          const Text(
                            'لكل ليلة',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF7F8C8D),
                            ),
                          ),
                        ],
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

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(
          Icons.home_outlined,
          size: 50,
          color: Color(0xFF7F8C8D),
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterBottomSheet(),
    );
  }

  Widget _buildFilterBottomSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'الفلاتر',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  TextButton(
                    onPressed: _clearFilters,
                    child: const Text(
                      'مسح الكل',
                      style: TextStyle(
                        color: Color(0xFF3498DB),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // City Filter
                    _buildFilterSection(
                      'المدينة',
                      DropdownButtonFormField<String>(
                        value: _selectedCity,
                        decoration: _getInputDecoration('اختر المدينة'),
                        items: _cities.map((city) {
                          return DropdownMenuItem(
                            value: city,
                            child: Text(city),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCity = value;
                          });
                        },
                      ),
                    ),
                    
                    // Type Filter
                    _buildFilterSection(
                      'نوع الإقامة',
                      DropdownButtonFormField<String>(
                        value: _selectedType,
                        decoration: _getInputDecoration('اختر النوع'),
                        items: _accommodationService.getAccommodationTypes().map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(_accommodationService.getAccommodationTypeNames()[type] ?? type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value;
                          });
                        },
                      ),
                    ),
                    
                    // Price Range
                    _buildFilterSection(
                      'نطاق السعر (دج)',
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: _getInputDecoration('الحد الأدنى'),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                _minPrice = double.tryParse(value);
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              decoration: _getInputDecoration('الحد الأقصى'),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                _maxPrice = double.tryParse(value);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Guests
                    _buildFilterSection(
                      'عدد الضيوف',
                      TextFormField(
                        decoration: _getInputDecoration('الحد الأدنى للضيوف'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _minGuests = int.tryParse(value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Apply Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _applyFilters();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3498DB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'تطبيق الفلاتر',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 8),
        child,
        const SizedBox(height: 20),
      ],
    );
  }

  InputDecoration _getInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade500),
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
    );
  }
}