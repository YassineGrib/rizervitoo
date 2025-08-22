import 'package:flutter/material.dart';
import '../../models/travel_agency.dart';
import '../../services/travel_agency_service.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import 'add_edit_travel_agency_screen.dart';
import 'travel_agency_offers_admin_screen.dart';
import '../../constants/app_styles.dart';

class TravelAgenciesAdminScreen extends StatefulWidget {
  const TravelAgenciesAdminScreen({super.key});

  @override
  State<TravelAgenciesAdminScreen> createState() => _TravelAgenciesAdminScreenState();
}

class _TravelAgenciesAdminScreenState extends State<TravelAgenciesAdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<TravelAgency> _agencies = [];
  List<TravelAgency> _filteredAgencies = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  String? _selectedWilaya;
  bool? _selectedActiveStatus;
  bool? _selectedVerifiedStatus;
  String _sortBy = 'created_at';
  int _currentPage = 0;
  final int _pageSize = 20;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Refresh UI when tab changes
    });
    _scrollController.addListener(_onScroll);
    _loadAgencies();
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
        _hasMoreData) {
      _loadMoreAgencies();
    }
  }

  Future<void> _loadAgencies() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final agencies = await TravelAgencyService.getAllAgenciesForAdmin(
        searchQuery: _searchController.text.trim(),
        wilaya: _selectedWilaya,
        isActive: _selectedActiveStatus,
        isVerified: _selectedVerifiedStatus,
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

  Future<void> _loadMoreAgencies() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final newAgencies = await TravelAgencyService.getAllAgenciesForAdmin(
        searchQuery: _searchController.text.trim(),
        wilaya: _selectedWilaya,
        isActive: _selectedActiveStatus,
        isVerified: _selectedVerifiedStatus,
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
          SnackBar(content: Text('خطأ في تحميل المزيد: ${e.toString()}', style: const TextStyle(fontFamily: 'Tajawal'))),
        );
      }
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedWilaya = null;
      _selectedActiveStatus = null;
      _selectedVerifiedStatus = null;
      _searchController.clear();
    });
    _loadAgencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'إدارة الوكالات السياحية',
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.bold,
          ),
        ),
        // backgroundColor: Theme.of(context).primaryColor,
         backgroundColor: AppStyles.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showStatistics,
            icon: const Icon(Icons.analytics),
            tooltip: 'الإحصائيات',
          ),
          if (_tabController.index == 0)
            IconButton(
              onPressed: _addNewAgency,
              icon: const Icon(Icons.add),
              tooltip: 'إضافة وكالة جديدة',
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              // icon: Icon(Icons.business),
              child: Text('الوكالات', style: TextStyle(fontFamily: 'Tajawal')),
            ),
            Tab(
              // icon: Icon(Icons.local_offer),
              child: Text('العروض', style: TextStyle(fontFamily: 'Tajawal')),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAgenciesTab(),
          const TravelAgencyOffersAdminScreen(),
        ],
      ),

    );
  }

  Widget _buildAgenciesTab() {
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
              hintText: 'البحث عن وكالة...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _loadAgencies();
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
            onSubmitted: (_) => _loadAgencies(),
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
                  label: _getActiveStatusLabel(),
                  icon: Icons.toggle_on,
                  onTap: _showActiveStatusSelector,
                  isSelected: _selectedActiveStatus != null,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: _getVerifiedStatusLabel(),
                  icon: Icons.verified,
                  onTap: _showVerifiedStatusSelector,
                  isSelected: _selectedVerifiedStatus != null,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: _getSortLabel(),
                  icon: Icons.sort,
                  onTap: _showSortOptions,
                  isSelected: _sortBy != 'created_at',
                ),
                const SizedBox(width: 8),
                if (_selectedWilaya != null ||
                    _selectedActiveStatus != null ||
                    _selectedVerifiedStatus != null)
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
        onRetry: _loadAgencies,
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
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAgencies,
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

  Widget _buildAgencyCard(TravelAgency agency) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with name and status badges
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
                // Status badges
                if (!agency.isActive)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.block,
                          size: 14,
                          color: Colors.red[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'معطلة',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 12,
                            color: Colors.red[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (agency.isVerified)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
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
                if (agency.email != null) ...[
                  const SizedBox(width: 16),
                  Icon(
                    Icons.email,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      agency.email!,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            // Rating and stats
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
                // Created date
                Text(
                  'أُنشئت: ${agency.createdAt != null ? _formatDate(agency.createdAt!) : 'غير محدد'}',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _editAgency(agency),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('تعديل', style: TextStyle(fontFamily: 'Tajawal')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                      side: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _manageOffers(agency),
                    icon: const Icon(Icons.local_offer, size: 16),
                    label: const Text('العروض', style: TextStyle(fontFamily: 'Tajawal')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: const BorderSide(color: Colors.orange),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleAgencyAction(agency, value),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'toggle_active',
                      child: Row(
                        children: [
                          Icon(
                            agency.isActive ? Icons.block : Icons.check_circle,
                            size: 16,
                            color: agency.isActive ? Colors.red : Colors.green,
                          ),
                          const SizedBox(width: 8),
                          Text(agency.isActive ? 'تعطيل' : 'تفعيل', style: TextStyle(fontFamily: 'Tajawal')),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle_verified',
                      child: Row(
                        children: [
                          Icon(
                            agency.isVerified ? Icons.verified_outlined : Icons.verified,
                            size: 16,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          Text(agency.isVerified ? 'إلغاء الاعتماد' : 'اعتماد', style: TextStyle(fontFamily: 'Tajawal')),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete,
                            size: 16,
                            color: Colors.red,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'حذف',
                            style: TextStyle(fontFamily: 'Tajawal', color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.more_vert,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addNewAgency() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditTravelAgencyScreen(),
      ),
    ).then((result) {
      if (result == true) {
        _loadAgencies();
      }
    });
  }

  void _editAgency(TravelAgency agency) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditTravelAgencyScreen(agency: agency),
      ),
    ).then((result) {
      if (result == true) {
        _loadAgencies();
      }
    });
  }

  void _manageOffers(TravelAgency agency) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TravelAgencyOffersAdminScreen(agencyId: agency.id),
      ),
    );
  }

  void _handleAgencyAction(TravelAgency agency, String action) async {
    try {
      switch (action) {
        case 'toggle_active':
          await TravelAgencyService.toggleAgencyStatus(agency.id, !agency.isActive);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                agency.isActive ? 'تم تعطيل الوكالة' : 'تم تفعيل الوكالة',
              ),
              backgroundColor: Colors.green,
            ),
          );
          break;
        case 'toggle_verified':
          await TravelAgencyService.verifyAgency(agency.id, !agency.isVerified);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                agency.isVerified ? 'تم إلغاء اعتماد الوكالة' : 'تم اعتماد الوكالة',
              ),
              backgroundColor: Colors.green,
            ),
          );
          break;
        case 'delete':
          final confirmed = await _showDeleteConfirmation(agency.name);
          if (confirmed) {
            await TravelAgencyService.deleteAgency(agency.id);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم حذف الوكالة'),
                backgroundColor: Colors.green,
              ),
            );
          }
          break;
      }
      _loadAgencies();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> _showDeleteConfirmation(String agencyName) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('تأكيد الحذف'),
            content: Text('هل أنت متأكد من حذف وكالة "$agencyName"؟\n\nسيتم حذف جميع العروض والتقييمات المرتبطة بها.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('حذف'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showStatistics() async {
    try {
      final stats = await TravelAgencyService.getStatistics();
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('إحصائيات الوكالات السياحية'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatRow('إجمالي الوكالات', stats['total_agencies'].toString()),
                  _buildStatRow('الوكالات المعتمدة', stats['verified_agencies'].toString()),
                  _buildStatRow('إجمالي العروض', stats['total_offers'].toString()),
                  _buildStatRow('إجمالي التقييمات', stats['total_reviews'].toString()),
                  const SizedBox(height: 16),
                  const Text(
                    'الوكالات حسب الولاية:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...((stats['agencies_by_wilaya'] as Map<String, dynamic>)
                      .entries
                      .map((entry) => _buildStatRow(entry.key, entry.value.toString()))
                      .toList()),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إغلاق'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في جلب الإحصائيات: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
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
                      title: Text(wilaya),
                      selected: _selectedWilaya == wilaya,
                      onTap: () {
                        setState(() {
                          _selectedWilaya = wilaya;
                        });
                        Navigator.pop(context);
                        _loadAgencies();
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

  void _showActiveStatusSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'حالة التفعيل',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('مفعلة'),
                selected: _selectedActiveStatus == true,
                onTap: () {
                  setState(() {
                    _selectedActiveStatus = true;
                  });
                  Navigator.pop(context);
                  _loadAgencies();
                },
              ),
              ListTile(
                title: const Text('معطلة'),
                selected: _selectedActiveStatus == false,
                onTap: () {
                  setState(() {
                    _selectedActiveStatus = false;
                  });
                  Navigator.pop(context);
                  _loadAgencies();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showVerifiedStatusSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'حالة الاعتماد',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('معتمدة'),
                selected: _selectedVerifiedStatus == true,
                onTap: () {
                  setState(() {
                    _selectedVerifiedStatus = true;
                  });
                  Navigator.pop(context);
                  _loadAgencies();
                },
              ),
              ListTile(
                title: const Text('غير معتمدة'),
                selected: _selectedVerifiedStatus == false,
                onTap: () {
                  setState(() {
                    _selectedVerifiedStatus = false;
                  });
                  Navigator.pop(context);
                  _loadAgencies();
                },
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
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('تاريخ الإنشاء'),
                selected: _sortBy == 'created_at',
                onTap: () {
                  setState(() {
                    _sortBy = 'created_at';
                  });
                  Navigator.pop(context);
                  _loadAgencies();
                },
              ),
              ListTile(
                title: const Text('الاسم'),
                selected: _sortBy == 'name',
                onTap: () {
                  setState(() {
                    _sortBy = 'name';
                  });
                  Navigator.pop(context);
                  _loadAgencies();
                },
              ),
              ListTile(
                title: const Text('التقييم'),
                selected: _sortBy == 'rating',
                onTap: () {
                  setState(() {
                    _sortBy = 'rating';
                  });
                  Navigator.pop(context);
                  _loadAgencies();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _getActiveStatusLabel() {
    if (_selectedActiveStatus == null) return 'حالة التفعيل';
    return _selectedActiveStatus! ? 'مفعلة' : 'معطلة';
  }

  String _getVerifiedStatusLabel() {
    if (_selectedVerifiedStatus == null) return 'حالة الاعتماد';
    return _selectedVerifiedStatus! ? 'معتمدة' : 'غير معتمدة';
  }

  String _getSortLabel() {
    switch (_sortBy) {
      case 'created_at':
        return 'تاريخ الإنشاء';
      case 'name':
        return 'الاسم';
      case 'rating':
        return 'التقييم';
      default:
        return 'ترتيب';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}