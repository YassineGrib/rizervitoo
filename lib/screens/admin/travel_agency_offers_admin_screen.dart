import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/travel_agency.dart';
import '../../services/travel_agency_service.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';

class TravelAgencyOffersAdminScreen extends StatefulWidget {
  final String? agencyId;

  const TravelAgencyOffersAdminScreen({super.key, this.agencyId});

  @override
  State<TravelAgencyOffersAdminScreen> createState() => _TravelAgencyOffersAdminScreenState();
}

class _TravelAgencyOffersAdminScreenState extends State<TravelAgencyOffersAdminScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<TravelAgencyOffer> _offers = [];
  List<TravelAgencyOffer> _filteredOffers = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  OfferCategory? _selectedCategory;
  DifficultyLevel? _selectedDifficulty;
  bool? _selectedActiveStatus;
  String _sortBy = 'created_at';
  int _currentPage = 0;
  final int _pageSize = 20;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadOffers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMoreData) {
      _loadMoreOffers();
    }
  }

  Future<void> _loadOffers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final offers = await TravelAgencyService.getAllOffersForAdmin(
        searchQuery: _searchController.text.trim(),
        agencyId: widget.agencyId,
        category: _selectedCategory?.name,
        isActive: _selectedActiveStatus,
        sortBy: _sortBy,
        limit: _pageSize,
        offset: 0,
      );

      setState(() {
        _offers = offers;
        _filteredOffers = List.from(_offers);
        _isLoading = false;
        _currentPage = 0;
        _hasMoreData = offers.length == _pageSize;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreOffers() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final newOffers = await TravelAgencyService.getAllOffersForAdmin(
        searchQuery: _searchController.text.trim(),
        agencyId: widget.agencyId,
        category: _selectedCategory?.name,
        isActive: _selectedActiveStatus,
        sortBy: _sortBy,
        limit: _pageSize,
        offset: (_currentPage + 1) * _pageSize,
      );

      setState(() {
        _currentPage++;
        _offers.addAll(newOffers);
        _filteredOffers = List.from(_offers);
        _hasMoreData = newOffers.length == _pageSize;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل المزيد: ${e.toString()}')),
        );
      }
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedDifficulty = null;
      _selectedActiveStatus = null;
      _searchController.clear();
    });
    _loadOffers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.agencyId != null
          ? AppBar(
              title: const Text(
                'عروض الوكالة',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
            )
          : null,
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: _buildOffersList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewOffer,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'إضافة عرض جديد',
      ),
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
              hintText: 'البحث عن عرض...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _loadOffers();
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
            onSubmitted: (_) => _loadOffers(),
          ),
          const SizedBox(height: 12),
          // Filters row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: _getCategoryLabel(),
                  icon: Icons.category,
                  onTap: _showCategorySelector,
                  isSelected: _selectedCategory != null,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: _getDifficultyLabel(),
                  icon: Icons.trending_up,
                  onTap: _showDifficultySelector,
                  isSelected: _selectedDifficulty != null,
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
                  label: _getSortLabel(),
                  icon: Icons.sort,
                  onTap: _showSortOptions,
                  isSelected: _sortBy != 'created_at',
                ),
                const SizedBox(width: 8),
                if (_selectedCategory != null ||
                    _selectedDifficulty != null ||
                    _selectedActiveStatus != null)
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

  Widget _buildOffersList() {
    if (_isLoading) {
      return const LoadingWidget();
    }

    if (_error != null) {
      return CustomErrorWidget(
        message: _error!,
        onRetry: _loadOffers,
      );
    }

    if (_filteredOffers.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_offer_outlined,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'لا توجد عروض',
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
      onRefresh: _loadOffers,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _filteredOffers.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _filteredOffers.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return _buildOfferCard(_filteredOffers[index]);
        },
      ),
    );
  }

  Widget _buildOfferCard(TravelAgencyOffer offer) {
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
            // Header with title and status
            Row(
              children: [
                Expanded(
                  child: Text(
                    offer.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (!offer.isActive)
                  Container(
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
                          'معطل',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Category and difficulty
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getCategoryDisplayName(offer.category),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(offer.difficultyLevel).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getDifficultyDisplayName(offer.difficultyLevel),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getDifficultyColor(offer.difficultyLevel),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Description
            if (offer.description != null)
              Text(
                offer.description!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 12),
            // Price and duration
            Row(
              children: [
                Icon(
                  Icons.attach_money,
                  size: 16,
                  color: Colors.green[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '${offer.priceDzd.toStringAsFixed(0)} دج',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[600],
                  ),
                ),
                const Spacer(),
                if (offer.durationDays != null) ...[
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${offer.durationDays} أيام',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            // Dates
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تاريخ البداية',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        _formatDate(offer.availableFrom!),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تاريخ النهاية',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        _formatDate(offer.availableTo!),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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
                    onPressed: () => _editOffer(offer),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('تعديل'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                      side: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleOfferAction(offer, value),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'toggle_active',
                      child: Row(
                        children: [
                          Icon(
                            offer.isActive ? Icons.block : Icons.check_circle,
                            size: 16,
                            color: offer.isActive ? Colors.red : Colors.green,
                          ),
                          const SizedBox(width: 8),
                          Text(offer.isActive ? 'تعطيل' : 'تفعيل'),
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
                            style: TextStyle(color: Colors.red),
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

  void _addNewOffer() {
    _showOfferDialog();
  }

  void _editOffer(TravelAgencyOffer offer) {
    _showOfferDialog(offer: offer);
  }

  void _showOfferDialog({TravelAgencyOffer? offer}) {
    showDialog(
      context: context,
      builder: (context) => OfferDialog(
        offer: offer,
        agencyId: widget.agencyId,
        onSaved: () {
          _loadOffers();
        },
      ),
    );
  }

  void _handleOfferAction(TravelAgencyOffer offer, String action) async {
    try {
      switch (action) {
        case 'toggle_active':
          await TravelAgencyService.toggleOfferStatus(offer.id, !offer.isActive);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                offer.isActive ? 'تم تعطيل العرض' : 'تم تفعيل العرض',
              ),
              backgroundColor: Colors.green,
            ),
          );
          break;
        case 'delete':
          final confirmed = await _showDeleteConfirmation(offer.title);
          if (confirmed) {
            await TravelAgencyService.deleteOffer(offer.id);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم حذف العرض'),
                backgroundColor: Colors.green,
              ),
            );
          }
          break;
      }
      _loadOffers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> _showDeleteConfirmation(String offerTitle) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('تأكيد الحذف'),
            content: Text('هل أنت متأكد من حذف العرض "$offerTitle"؟'),
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

  // Filter and sort methods
  void _showCategorySelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'اختر الفئة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: OfferCategory.values.length,
                  itemBuilder: (context, index) {
                    final category = OfferCategory.values[index];
                    return ListTile(
                      title: Text(_getCategoryDisplayName(category.toString().split('.').last)),
                      selected: _selectedCategory == category,
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                        Navigator.pop(context);
                        _loadOffers();
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

  void _showDifficultySelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'اختر مستوى الصعوبة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...DifficultyLevel.values.map((difficulty) {
                return ListTile(
                  title: Text(_getDifficultyDisplayName(difficulty.toString().split('.').last)),
                  selected: _selectedDifficulty == difficulty,
                  onTap: () {
                    setState(() {
                      _selectedDifficulty = difficulty;
                    });
                    Navigator.pop(context);
                    _loadOffers();
                  },
                );
              }).toList(),
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
                title: const Text('مفعل'),
                selected: _selectedActiveStatus == true,
                onTap: () {
                  setState(() {
                    _selectedActiveStatus = true;
                  });
                  Navigator.pop(context);
                  _loadOffers();
                },
              ),
              ListTile(
                title: const Text('معطل'),
                selected: _selectedActiveStatus == false,
                onTap: () {
                  setState(() {
                    _selectedActiveStatus = false;
                  });
                  Navigator.pop(context);
                  _loadOffers();
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
                  _loadOffers();
                },
              ),
              ListTile(
                title: const Text('العنوان'),
                selected: _sortBy == 'title',
                onTap: () {
                  setState(() {
                    _sortBy = 'title';
                  });
                  Navigator.pop(context);
                  _loadOffers();
                },
              ),
              ListTile(
                title: const Text('السعر'),
                selected: _sortBy == 'price',
                onTap: () {
                  setState(() {
                    _sortBy = 'price';
                  });
                  Navigator.pop(context);
                  _loadOffers();
                },
              ),
              ListTile(
                title: const Text('تاريخ البداية'),
                selected: _sortBy == 'start_date',
                onTap: () {
                  setState(() {
                    _sortBy = 'start_date';
                  });
                  Navigator.pop(context);
                  _loadOffers();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper methods
  String _getCategoryLabel() {
    if (_selectedCategory == null) return 'الفئة';
    return _getCategoryDisplayName(_selectedCategory!.toString().split('.').last);
  }

  String _getDifficultyLabel() {
    if (_selectedDifficulty == null) return 'الصعوبة';
    return _getDifficultyDisplayName(_selectedDifficulty!.toString().split('.').last);
  }

  String _getActiveStatusLabel() {
    if (_selectedActiveStatus == null) return 'الحالة';
    return _selectedActiveStatus! ? 'مفعل' : 'معطل';
  }

  String _getSortLabel() {
    switch (_sortBy) {
      case 'created_at':
        return 'تاريخ الإنشاء';
      case 'title':
        return 'العنوان';
      case 'price':
        return 'السعر';
      case 'start_date':
        return 'تاريخ البداية';
      default:
        return 'ترتيب';
    }
  }

  String _getCategoryDisplayName(String? category) {
    final offerCategory = _parseOfferCategory(category);
    switch (offerCategory) {
      case OfferCategory.domestic:
        return 'داخلية';
      case OfferCategory.international:
        return 'خارجية';
      case OfferCategory.umrah:
        return 'عمرة';
      case OfferCategory.hajj:
        return 'حج';
      case OfferCategory.weekend:
        return 'نهاية أسبوع';
      case OfferCategory.holiday:
        return 'عطلة';
      case OfferCategory.adventure:
        return 'مغامرة';
      case OfferCategory.cultural:
        return 'ثقافية';
      case OfferCategory.beach:
        return 'شاطئية';
      case OfferCategory.mountain:
        return 'جبلية';
      case OfferCategory.desert:
        return 'صحراوية';
      default:
        return 'داخلية';
    }
  }

  String _getDifficultyDisplayName(String? difficulty) {
    final difficultyLevel = _parseDifficultyLevel(difficulty);
    switch (difficultyLevel) {
      case DifficultyLevel.easy:
        return 'سهل';
      case DifficultyLevel.moderate:
        return 'متوسط';
      case DifficultyLevel.hard:
        return 'صعب';
      case DifficultyLevel.expert:
        return 'خبير';
      default:
        return 'سهل';
    }
  }

  Color _getDifficultyColor(String? difficulty) {
    final difficultyLevel = _parseDifficultyLevel(difficulty);
    switch (difficultyLevel) {
      case DifficultyLevel.easy:
        return Colors.green;
      case DifficultyLevel.moderate:
        return Colors.orange;
      case DifficultyLevel.hard:
        return Colors.red;
      case DifficultyLevel.expert:
        return Colors.deepPurple;
    }
  }

  // Parse helpers for this state class
  OfferCategory _parseOfferCategory(String? category) {
    if (category == null) return OfferCategory.domestic;
    try {
      return OfferCategory.values.firstWhere(
        (e) => e.toString().split('.').last == category,
        orElse: () => OfferCategory.domestic,
      );
    } catch (e) {
      return OfferCategory.domestic;
    }
  }

  DifficultyLevel _parseDifficultyLevel(String? difficulty) {
    if (difficulty == null) return DifficultyLevel.easy;
    try {
      return DifficultyLevel.values.firstWhere(
        (e) => e.toString().split('.').last == difficulty,
        orElse: () => DifficultyLevel.easy,
      );
    } catch (e) {
      return DifficultyLevel.easy;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Offer Dialog for adding/editing offers
class OfferDialog extends StatefulWidget {
  final TravelAgencyOffer? offer;
  final String? agencyId;
  final VoidCallback onSaved;

  const OfferDialog({
    super.key,
    this.offer,
    this.agencyId,
    required this.onSaved,
  });

  @override
  State<OfferDialog> createState() => _OfferDialogState();
}

class _OfferDialogState extends State<OfferDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  final _maxParticipantsController = TextEditingController();
  
  OfferCategory _selectedCategory = OfferCategory.domestic;
  DifficultyLevel _selectedDifficulty = DifficultyLevel.easy;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isActive = true;
  bool _isLoading = false;
  
  bool get _isEditing => widget.offer != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _populateFields();
    }
  }

  void _populateFields() {
    final offer = widget.offer!;
    _titleController.text = offer.title;
    _descriptionController.text = offer.description ?? '';
    _priceController.text = offer.priceDzd.toString();
    _durationController.text = offer.durationDays.toString();
    _maxParticipantsController.text = offer.maxParticipants?.toString() ?? '';
    _selectedCategory = _parseOfferCategory(offer.category);
    _selectedDifficulty = _parseDifficultyLevel(offer.difficultyLevel);
    _startDate = offer.availableFrom;
    _endDate = offer.availableTo;
    _isActive = offer.isActive;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _maxParticipantsController.dispose();
    super.dispose();
  }

  OfferCategory _parseOfferCategory(String? category) {
    if (category == null) return OfferCategory.domestic;
    try {
      return OfferCategory.values.firstWhere(
        (e) => e.toString().split('.').last == category,
        orElse: () => OfferCategory.domestic,
      );
    } catch (e) {
      return OfferCategory.domestic;
    }
  }

  DifficultyLevel _parseDifficultyLevel(String? difficulty) {
    if (difficulty == null) return DifficultyLevel.easy;
    try {
      return DifficultyLevel.values.firstWhere(
        (e) => e.toString().split('.').last == difficulty,
        orElse: () => DifficultyLevel.easy,
      );
    } catch (e) {
      return DifficultyLevel.easy;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'تعديل العرض' : 'إضافة عرض جديد'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'عنوان العرض *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'عنوان العرض مطلوب';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'وصف العرض',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Column(
                  children: [
                    DropdownButtonFormField<OfferCategory>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'الفئة *',
                        border: OutlineInputBorder(),
                      ),
                      items: OfferCategory.values.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(
                            _getCategoryDisplayName(category.toString().split('.').last),
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<DifficultyLevel>(
                      value: _selectedDifficulty,
                      decoration: const InputDecoration(
                        labelText: 'الصعوبة *',
                        border: OutlineInputBorder(),
                      ),
                      items: DifficultyLevel.values.map((difficulty) {
                        return DropdownMenuItem(
                          value: difficulty,
                          child: Text(
                            _getDifficultyDisplayName(difficulty.toString().split('.').last),
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDifficulty = value!;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'السعر (دج) *',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'السعر مطلوب';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _durationController,
                        decoration: const InputDecoration(
                          labelText: 'المدة (أيام)',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _maxParticipantsController,
                  decoration: const InputDecoration(
                    labelText: 'الحد الأقصى للمشاركين',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
                const SizedBox(height: 16),
                Column(
                  children: [
                    InkWell(
                      onTap: () => _selectStartDate(),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'تاريخ البداية *',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _startDate != null
                                        ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                        : 'اختر التاريخ',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                const Icon(Icons.calendar_today, size: 20),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => _selectEndDate(),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'تاريخ النهاية *',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _endDate != null
                                        ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                        : 'اختر التاريخ',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                const Icon(Icons.calendar_today, size: 20),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('العرض مفعل'),
                  value: _isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveOffer,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_isEditing ? 'تحديث' : 'إضافة'),
        ),
      ],
    );
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date != null) {
      setState(() {
        _startDate = date;
        if (_endDate != null && _endDate!.isBefore(date)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate?.add(const Duration(days: 1)) ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date != null) {
      setState(() {
        _endDate = date;
      });
    }
  }

  Future<void> _saveOffer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار تاريخ البداية والنهاية'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final offerData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        'category': _selectedCategory.name,
        'difficulty': _selectedDifficulty.name,
        'price': double.parse(_priceController.text),
        'duration': _durationController.text.trim().isEmpty
            ? null
            : int.parse(_durationController.text),
        'max_participants': _maxParticipantsController.text.trim().isEmpty
            ? null
            : int.parse(_maxParticipantsController.text),
        'start_date': _startDate!.toIso8601String(),
        'end_date': _endDate!.toIso8601String(),
        'is_active': _isActive,
      };

      if (widget.agencyId != null) {
        offerData['agency_id'] = widget.agencyId!;
      }

      if (_isEditing) {
        await TravelAgencyService.updateOffer(widget.offer!.id, offerData);
      } else {
        await TravelAgencyService.createOffer(offerData);
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onSaved();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'تم تحديث العرض بنجاح' : 'تم إنشاء العرض بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getCategoryDisplayName(String? category) {
    final offerCategory = _parseOfferCategory(category);
    switch (offerCategory) {
      case OfferCategory.domestic:
        return 'داخلية';
      case OfferCategory.international:
        return 'خارجية';
      case OfferCategory.umrah:
        return 'عمرة';
      case OfferCategory.hajj:
        return 'حج';
      case OfferCategory.weekend:
        return 'نهاية أسبوع';
      case OfferCategory.holiday:
        return 'عطلة';
      case OfferCategory.adventure:
        return 'مغامرة';
      case OfferCategory.cultural:
        return 'ثقافية';
      case OfferCategory.beach:
        return 'شاطئية';
      case OfferCategory.mountain:
        return 'جبلية';
      case OfferCategory.desert:
        return 'صحراوية';
    }
    return 'داخلية'; // Default fallback
  }

  String _getDifficultyDisplayName(String? difficulty) {
    final difficultyLevel = _parseDifficultyLevel(difficulty);
    switch (difficultyLevel) {
      case DifficultyLevel.easy:
        return 'سهل';
      case DifficultyLevel.moderate:
        return 'متوسط';
      case DifficultyLevel.hard:
        return 'صعب';
      case DifficultyLevel.expert:
        return 'خبير';
    }
    return 'سهل'; // Default fallback
  }
}