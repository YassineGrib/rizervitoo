import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import '../constants/app_styles.dart';
import '../models/travel_guide.dart';
import 'admin_travel_guide_form_screen.dart';

class AdminTravelGuidesScreen extends StatefulWidget {
  const AdminTravelGuidesScreen({super.key});

  @override
  State<AdminTravelGuidesScreen> createState() => _AdminTravelGuidesScreenState();
}

class _AdminTravelGuidesScreenState extends State<AdminTravelGuidesScreen> {
  List<TravelGuide> _guides = [];
  List<TravelGuide> _filteredGuides = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all'; // all, published, draft

  @override
  void initState() {
    super.initState();
    _loadTravelGuides();
    _searchController.addListener(_filterGuides);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTravelGuides() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final guides = await AdminService.getAllTravelGuides();
      
      if (mounted) {
        setState(() {
          _guides = guides;
          _filteredGuides = guides;
          _isLoading = false;
        });
        _filterGuides();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _filterGuides() {
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      _filteredGuides = _guides.where((guide) {
        final matchesSearch = guide.title.toLowerCase().contains(query) ||
            guide.location.toLowerCase().contains(query) ||
            guide.category.toLowerCase().contains(query);
        
        final matchesFilter = _selectedFilter == 'all' ||
            (_selectedFilter == 'published' && guide.isPublished) ||
            (_selectedFilter == 'draft' && !guide.isPublished);
        
        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  Future<void> _deleteGuide(TravelGuide guide) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'حذف الدليل السياحي',
          style: TextStyle(fontFamily: 'Amiri'),
        ),
        content: Text(
          'هل أنت متأكد من حذف "${guide.title}"؟\nلا يمكن التراجع عن هذا الإجراء.',
          style: const TextStyle(fontFamily: 'Tajawal'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'إلغاء',
              style: TextStyle(fontFamily: 'Tajawal'),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'حذف',
              style: TextStyle(fontFamily: 'Tajawal'),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await AdminService.deleteTravelGuide(guide.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'تم حذف الدليل السياحي بنجاح',
                style: TextStyle(fontFamily: 'Tajawal'),
              ),
              backgroundColor: Colors.green,
            ),
          );
          _loadTravelGuides();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'فشل في حذف الدليل السياحي: ${e.toString()}',
                style: const TextStyle(fontFamily: 'Tajawal'),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _togglePublication(TravelGuide guide) async {
    try {
      await AdminService.toggleGuidePublication(guide.id, !guide.isPublished);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              guide.isPublished ? 'تم إلغاء نشر الدليل السياحي' : 'تم نشر الدليل السياحي',
              style: const TextStyle(fontFamily: 'Tajawal'),
            ),
            backgroundColor: Colors.green,
          ),
        );
        _loadTravelGuides();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'فشل في تغيير حالة النشر: ${e.toString()}',
              style: const TextStyle(fontFamily: 'Tajawal'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'إدارة الأدلة السياحية',
          style: TextStyle(
            fontFamily: 'Amiri',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppStyles.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTravelGuides,
            tooltip: 'تحديث',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AdminTravelGuideFormScreen(),
            ),
          );
          if (result == true) {
            _loadTravelGuides();
          }
        },
        backgroundColor: AppStyles.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'البحث في الأدلة السياحية...',
                    hintStyle: const TextStyle(fontFamily: 'Tajawal'),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppStyles.primaryColor),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 12),
                
                // Filter Chips
                Row(
                  children: [
                    _buildFilterChip('الكل', 'all'),
                    const SizedBox(width: 8),
                    _buildFilterChip('منشور', 'published'),
                    const SizedBox(width: 8),
                    _buildFilterChip('مسودة', 'draft'),
                  ],
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'حدث خطأ في تحميل البيانات',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                                fontFamily: 'Amiri',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontFamily: 'Tajawal',
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _loadTravelGuides,
                              child: const Text(
                                'إعادة المحاولة',
                                style: TextStyle(fontFamily: 'Tajawal'),
                              ),
                            ),
                          ],
                        ),
                      )
                    : _filteredGuides.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.map_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'لا توجد أدلة سياحية',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                    fontFamily: 'Amiri',
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'ابدأ بإضافة دليل سياحي جديد',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontFamily: 'Tajawal',
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadTravelGuides,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredGuides.length,
                              itemBuilder: (context, index) {
                                final guide = _filteredGuides[index];
                                return _buildGuideCard(guide);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[700],
          fontFamily: 'Tajawal',
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
        _filterGuides();
      },
      backgroundColor: Colors.grey[200],
      selectedColor: AppStyles.primaryColor,
      checkmarkColor: Colors.white,
    );
  }

  Widget _buildGuideCard(TravelGuide guide) {
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
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        guide.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Amiri',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${guide.location} - ${guide.category}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: guide.isPublished
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    guide.isPublished ? 'منشور' : 'مسودة',
                    style: TextStyle(
                      color: guide.isPublished ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
              ],
            ),
            
            if (guide.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                guide.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontFamily: 'Tajawal',
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Stats
            Row(
              children: [
                _buildStatChip(Icons.visibility, guide.viewCount.toString()),
                const SizedBox(width: 12),
                _buildStatChip(Icons.star, '0.0'), // Rating not implemented yet
                const SizedBox(width: 12),
                _buildStatChip(Icons.reviews, '0'), // Reviews not implemented yet
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AdminTravelGuideFormScreen(guide: guide),
                        ),
                      );
                      if (result == true) {
                        _loadTravelGuides();
                      }
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text(
                      'تعديل',
                      style: TextStyle(fontFamily: 'Tajawal'),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppStyles.primaryColor,
                      side: BorderSide(color: AppStyles.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _togglePublication(guide),
                    icon: Icon(
                      guide.isPublished ? Icons.visibility_off : Icons.publish,
                      size: 18,
                    ),
                    label: Text(
                      guide.isPublished ? 'إلغاء النشر' : 'نشر',
                      style: const TextStyle(fontFamily: 'Tajawal'),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: guide.isPublished ? Colors.orange : Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _deleteGuide(guide),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'حذف',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}