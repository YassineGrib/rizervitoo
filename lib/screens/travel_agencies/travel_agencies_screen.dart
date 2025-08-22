import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/travel_agency.dart';
import '../../services/travel_agency_service.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import 'travel_agency_details_screen.dart';
import '../../constants/app_styles.dart';

class TravelAgenciesScreen extends StatefulWidget {
  const TravelAgenciesScreen({super.key});

  @override
  State<TravelAgenciesScreen> createState() => _TravelAgenciesScreenState();
}

class _TravelAgenciesScreenState extends State<TravelAgenciesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<TravelAgency> _agencies = [];
  List<TravelAgency> _filteredAgencies = [];
  List<TravelAgency> _featuredAgencies = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  String? _selectedWilaya;
  String? _selectedSpecialty;
  String _sortBy = 'rating';
  int _currentPage = 0;
  final int _pageSize = 20;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMoreData &&
        _tabController.index == 0) {
      _loadMoreAgencies();
    }
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final futures = await Future.wait([
        TravelAgencyService.getFeaturedAgencies(limit: 10),
        TravelAgencyService.getAllAgencies(
          limit: _pageSize,
          offset: 0,
          sortBy: _sortBy,
        ),
      ]);

      setState(() {
        _featuredAgencies = futures[0] as List<TravelAgency>;
        _agencies = futures[1] as List<TravelAgency>;
        _filteredAgencies = List.from(_agencies);
        _isLoading = false;
        _currentPage = 0;
        _hasMoreData = _agencies.length == _pageSize;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreAgencies() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final newAgencies = await TravelAgencyService.getAllAgencies(
        wilaya: _selectedWilaya,
        specialty: _selectedSpecialty,
        searchQuery: _searchController.text.trim(),
        sortBy: _sortBy,
        limit: _pageSize,
        offset: (_currentPage + 1) * _pageSize,
      );

      setState(() {
        _currentPage++;
        _agencies.addAll(newAgencies);
        _filteredAgencies = List.from(_agencies);
        _hasMoreData = newAgencies.length == _pageSize;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'خطأ في تحميل المزيد: ${e.toString()}',
              style: const TextStyle(fontFamily: 'Tajawal'),
            ),
          ),
        );
      }
    }
  }

  Future<void> _searchAgencies() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final agencies = await TravelAgencyService.getAllAgencies(
        wilaya: _selectedWilaya,
        specialty: _selectedSpecialty,
        searchQuery: _searchController.text.trim(),
        sortBy: _sortBy,
        limit: _pageSize,
        offset: 0,
      );

      setState(() {
        _agencies = agencies;
        _filteredAgencies = List.from(_agencies);
        _isLoading = false;
        _currentPage = 0;
        _hasMoreData = agencies.length == _pageSize;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedWilaya = null;
      _selectedSpecialty = null;
      _searchController.clear();
    });
    _loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'دليل الوكالات السياحية',
          style: TextStyle(
            fontFamily: 'Amiri',
            fontWeight: FontWeight.bold,
          ),
        ),
        // backgroundColor: Theme.of(context).primaryColor,
        backgroundColor: AppStyles.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontFamily: 'Tajawal'),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Tajawal'),
          tabs: const [
            Tab(
              // icon: Icon(Icons.business),
              text: 'جميع الوكالات',
            ),
            Tab(
              // icon: Icon(Icons.star),
              text: 'المميزة',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllAgenciesTab(),
          _buildFeaturedTab(),
        ],
      ),
    );
  }

  Widget _buildFeaturedTab() {
    if (_isLoading) {
      return const LoadingWidget();
    }

    if (_error != null) {
      return CustomErrorWidget(
        message: _error!,
        onRetry: _loadInitialData,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInitialData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الوكالات المميزة',
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'أفضل الوكالات السياحية المعتمدة في الجزائر',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            if (_featuredAgencies.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'لا توجد وكالات مميزة حالياً',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _featuredAgencies.length,
                itemBuilder: (context, index) {
                  return _buildAgencyCard(_featuredAgencies[index], isFeatured: true);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllAgenciesTab() {
    return Column(
      children: [
        _buildSearchAndFilters(),
        Expanded(
          child: _buildAgenciesList(),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'البحث عن وكالة سياحية...',
              hintStyle: const TextStyle(fontFamily: 'Tajawal'),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _searchAgencies();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onSubmitted: (_) => _searchAgencies(),
          ),
          const SizedBox(height: 12),
          // Filters row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: _selectedWilaya ?? 'الولاية',
                  icon: Icons.location_on,
                  onTap: _showWilayaSelector,
                  isSelected: _selectedWilaya != null,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: _selectedSpecialty ?? 'التخصص',
                  icon: Icons.category,
                  onTap: _showSpecialtySelector,
                  isSelected: _selectedSpecialty != null,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: _getSortLabel(),
                  icon: Icons.sort,
                  onTap: _showSortOptions,
                  isSelected: _sortBy != 'rating',
                ),
                const SizedBox(width: 8),
                if (_selectedWilaya != null || _selectedSpecialty != null)
                  _buildFilterChip(
                    label: 'مسح الفلاتر',
                    icon: Icons.clear,
                    onTap: _clearFilters,
                    isSelected: false,
                    isAction: true,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required bool isSelected,
    bool isAction = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : isAction
                  ? Colors.red[50]
                  : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : isAction
                    ? Colors.red[300]!
                    : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? Colors.white
                  : isAction
                      ? Colors.red[600]
                      : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 12,
                color: isSelected
                    ? Colors.white
                    : isAction
                        ? Colors.red[600]
                        : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgenciesList() {
    if (_isLoading) {
      return const LoadingWidget();
    }

    if (_error != null) {
      return CustomErrorWidget(
        message: _error!,
        onRetry: _searchAgencies,
      );
    }

    if (_filteredAgencies.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.business_outlined,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'لا توجد وكالات سياحية',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'جرب تغيير معايير البحث أو الفلاتر',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _searchAgencies,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _filteredAgencies.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _filteredAgencies.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return _buildAgencyCard(_filteredAgencies[index]);
        },
      ),
    );
  }

  Widget _buildAgencyCard(TravelAgency agency, {bool isFeatured = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isFeatured ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isFeatured
            ? BorderSide(color: Colors.amber, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TravelAgencyDetailsScreen(agencyId: agency.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with name and verification
              Row(
                children: [
                  Expanded(
                    child: Text(
                      agency.name,
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (agency.isVerified)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified,
                            size: 14,
                            color: Colors.blue[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'معتمدة',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 12,
                              color: Colors.blue[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (isFeatured)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.amber[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'مميزة',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 12,
                              color: Colors.amber[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Location and contact
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${agency.address}, ${agency.wilaya}',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.phone,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    agency.phone,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  // Call button
                  IconButton(
                    onPressed: () => _makePhoneCall(agency.phone),
                    icon: const Icon(Icons.call),
                    color: Colors.green,
                    tooltip: 'اتصال',
                  ),
                ],
              ),
              if (agency.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  agency.description!,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              // Rating and specialties
              Row(
                children: [
                  // Rating
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        agency.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${agency.totalReviews})',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Specialties
                  if (agency.specialties.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      children: agency.specialties.take(2).map((specialty) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            specialty,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 10,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _makePhoneCall(String phoneNumber) async {
    try {
      // Remove any non-digit characters except +
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      await Clipboard.setData(ClipboardData(text: cleanNumber));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم نسخ رقم الهاتف: $cleanNumber',
              style: const TextStyle(fontFamily: 'Tajawal'),
            ),
            action: SnackBarAction(
              label: 'اتصال',
              textColor: Colors.white,
              onPressed: () {
                // Here you would typically use url_launcher to make the call
                // For now, we'll just show the number
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'خطأ في نسخ رقم الهاتف',
              style: TextStyle(fontFamily: 'Tajawal'),
            ),
          ),
        );
      }
    }
  }

  void _showWilayaSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'اختر الولاية',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: AlgerianWilayas.all.length,
                  itemBuilder: (context, index) {
                    final wilaya = AlgerianWilayas.all[index];
                    return ListTile(
                      title: Text(
                        wilaya,
                        style: const TextStyle(fontFamily: 'Tajawal'),
                      ),
                      selected: _selectedWilaya == wilaya,
                      onTap: () {
                        setState(() {
                          _selectedWilaya = wilaya;
                        });
                        Navigator.pop(context);
                        _searchAgencies();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSpecialtySelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'اختر التخصص',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: AgencySpecialty.values.length,
                  itemBuilder: (context, index) {
                    final specialty = AgencySpecialty.values[index];
                    final specialtyName = specialty.arabicName;
                    return ListTile(
                      title: Text(
                        specialtyName,
                        style: const TextStyle(fontFamily: 'Tajawal'),
                      ),
                      selected: _selectedSpecialty == specialtyName,
                      onTap: () {
                        setState(() {
                          _selectedSpecialty = specialtyName;
                        });
                        Navigator.pop(context);
                        _searchAgencies();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'ترتيب حسب',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text(
                  'التقييم',
                  style: TextStyle(fontFamily: 'Tajawal'),
                ),
                selected: _sortBy == 'rating',
                onTap: () {
                  setState(() {
                    _sortBy = 'rating';
                  });
                  Navigator.pop(context);
                  _searchAgencies();
                },
              ),
              ListTile(
                title: const Text(
                  'الاسم',
                  style: TextStyle(fontFamily: 'Tajawal'),
                ),
                selected: _sortBy == 'name',
                onTap: () {
                  setState(() {
                    _sortBy = 'name';
                  });
                  Navigator.pop(context);
                  _searchAgencies();
                },
              ),
              ListTile(
                title: const Text(
                  'الأحدث',
                  style: TextStyle(fontFamily: 'Tajawal'),
                ),
                selected: _sortBy == 'created_at',
                onTap: () {
                  setState(() {
                    _sortBy = 'created_at';
                  });
                  Navigator.pop(context);
                  _searchAgencies();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _getSortLabel() {
    switch (_sortBy) {
      case 'rating':
        return 'التقييم';
      case 'name':
        return 'الاسم';
      case 'created_at':
        return 'الأحدث';
      default:
        return 'ترتيب';
    }
  }
}