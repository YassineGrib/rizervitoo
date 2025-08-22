import 'package:flutter/material.dart';
import '../models/travel_guide.dart';
import '../services/travel_guide_service.dart';

class TravelGuideDetailScreen extends StatefulWidget {
  final TravelGuide guide;

  const TravelGuideDetailScreen({super.key, required this.guide});

  @override
  State<TravelGuideDetailScreen> createState() => _TravelGuideDetailScreenState();
}

class _TravelGuideDetailScreenState extends State<TravelGuideDetailScreen>
    with SingleTickerProviderStateMixin {
  final TravelGuideService _travelGuideService = TravelGuideService();
  final ScrollController _scrollController = ScrollController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isAppBarCollapsed = false;
  List<TravelGuide> _relatedGuides = [];
  bool _isLoadingRelated = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _scrollController.addListener(_onScroll);
    _animationController.forward();
    _incrementViewCount();
    _loadRelatedGuides();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final isCollapsed = _scrollController.offset > 200;
    if (isCollapsed != _isAppBarCollapsed) {
      setState(() {
        _isAppBarCollapsed = isCollapsed;
      });
    }
  }

  Future<void> _incrementViewCount() async {
    await _travelGuideService.incrementViewCount(widget.guide.id);
  }

  Future<void> _loadRelatedGuides() async {
    try {
      final guides = await _travelGuideService.getTravelGuidesByCategory(
        widget.guide.category,
        limit: 5,
      );
      
      setState(() {
        _relatedGuides = guides.where((g) => g.id != widget.guide.id).toList();
        _isLoadingRelated = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingRelated = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      _buildContent(),
                      _buildTags(),
                      _buildLocationInfo(),
                      _buildRelatedGuides(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: const Color(0xFF2E7D32),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _shareGuide,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: _isAppBarCollapsed
            ? Text(
                widget.guide.title,
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        background: Stack(
          fit: StackFit.expand,
          children: [
            widget.guide.imageUrl != null
                ? Image.network(
                    widget.guide.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholderImage();
                    },
                  )
                : _buildPlaceholderImage(),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            // Category badge
            Positioned(
              top: 100,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF388E3C)],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  widget.guide.categoryDisplayName,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2E7D32).withOpacity(0.3),
            const Color(0xFF2E7D32).withOpacity(0.7),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.explore,
          size: 80,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            widget.guide.title,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          // Location and stats
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 20,
                      color: Color(0xFF2E7D32),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.guide.location,
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 16,
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.w600,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF2E7D32).withOpacity(0.1),
                      const Color(0xFF388E3C).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF2E7D32).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${widget.guide.formattedViewCount} مشاهدة',
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 12,
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.visibility,
                      size: 16,
                      color: Color(0xFF2E7D32),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Description
          Text(
            widget.guide.description,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.6,
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.article,
                  color: Color(0xFF2E7D32),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'تفاصيل الدليل',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.guide.content,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 16,
              color: Color(0xFF424242),
              height: 1.8,
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  Widget _buildTags() {
    if (widget.guide.tags.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الكلمات المفتاحية',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.guide.tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF2E7D32).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12,
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
    if (widget.guide.latitude == null || widget.guide.longitude == null) {
      return const SizedBox();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.map,
                  color: Color(0xFF2E7D32),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'معلومات الموقع',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Color(0xFF2E7D32),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.guide.location,
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.gps_fixed,
                      color: Colors.grey,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'خط العرض: ${widget.guide.latitude!.toStringAsFixed(6)}',
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.gps_fixed,
                      color: Colors.grey,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'خط الطول: ${widget.guide.longitude!.toStringAsFixed(6)}',
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _openInMaps,
                    icon: const Icon(Icons.map, size: 18),
                    label: const Text(
                      'فتح في الخرائط',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedGuides() {
    if (_isLoadingRelated) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(
            color: Color(0xFF2E7D32),
          ),
        ),
      );
    }

    if (_relatedGuides.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'أدلة ذات صلة',
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              reverse: false,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _relatedGuides.length,
              itemBuilder: (context, index) {
                final guide = _relatedGuides[index];
                return _buildRelatedGuideCard(guide);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedGuideCard(TravelGuide guide) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TravelGuideDetailScreen(guide: guide),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Container(
                height: 100,
                width: double.infinity,
                child: guide.imageUrl != null
                    ? Image.network(
                        guide.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF2E7D32).withOpacity(0.3),
                                  const Color(0xFF2E7D32).withOpacity(0.5),
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.explore,
                              color: Colors.white,
                              size: 30,
                            ),
                          );
                        },
                      )
                    : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF2E7D32).withOpacity(0.3),
                              const Color(0xFF2E7D32).withOpacity(0.5),
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.explore,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guide.title,
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      guide.location,
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 12,
                        color: Color(0xFF2E7D32),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareGuide() {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'ميزة المشاركة قيد التطوير',
          style: TextStyle(fontFamily: 'Tajawal'),
        ),
        backgroundColor: Color(0xFF2E7D32),
      ),
    );
  }

  void _openInMaps() {
    // TODO: Implement open in maps functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'ميزة فتح الخرائط قيد التطوير',
          style: TextStyle(fontFamily: 'Tajawal'),
        ),
        backgroundColor: Color(0xFF2E7D32),
      ),
    );
  }
}