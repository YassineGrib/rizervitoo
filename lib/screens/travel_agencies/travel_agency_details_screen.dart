import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/travel_agency.dart';
import '../../services/travel_agency_service.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';

class TravelAgencyDetailsScreen extends StatefulWidget {
  final String agencyId;

  const TravelAgencyDetailsScreen({
    super.key,
    required this.agencyId,
  });

  @override
  State<TravelAgencyDetailsScreen> createState() => _TravelAgencyDetailsScreenState();
}

class _TravelAgencyDetailsScreenState extends State<TravelAgencyDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TravelAgency? _agency;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAgencyDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAgencyDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final agency = await TravelAgencyService.getAgencyById(widget.agencyId);
      setState(() {
        _agency = agency;
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
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('تفاصيل الوكالة', style: TextStyle(fontFamily: 'Tajawal')),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const LoadingWidget(),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('تفاصيل الوكالة', style: TextStyle(fontFamily: 'Tajawal')),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        body: CustomErrorWidget(
          message: _error!,
          onRetry: _loadAgencyDetails,
        ),
      );
    }

    if (_agency == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('تفاصيل الوكالة', style: TextStyle(fontFamily: 'Tajawal')),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('الوكالة غير موجودة', style: TextStyle(fontFamily: 'Tajawal')),
        ),
      );
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  _agency!.name,
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 3,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: _buildAgencyHeader(),
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: Theme.of(context).primaryColor,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.info),
                      child: Text('معلومات', style: TextStyle(fontFamily: 'Tajawal')),
                    ),
                    Tab(
                      icon: Icon(Icons.local_offer),
                      child: Text('العروض', style: TextStyle(fontFamily: 'Tajawal')),
                    ),
                    Tab(
                      icon: Icon(Icons.star),
                      child: Text('التقييمات', style: TextStyle(fontFamily: 'Tajawal')),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildInfoTab(),
            _buildOffersTab(),
            _buildReviewsTab(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAgencyHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (_agency!.isVerified)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'معتمدة',
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber[300],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _agency!.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${_agency!.totalReviews} تقييم)',
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contact Information
          _buildInfoSection(
            title: 'معلومات الاتصال',
            icon: Icons.contact_phone,
            children: [
              _buildInfoRow(
                icon: Icons.location_on,
                label: 'العنوان',
                value: '${_agency!.address}, ${_agency!.wilaya}',
              ),
              _buildInfoRow(
                icon: Icons.phone,
                label: 'الهاتف',
                value: _agency!.phone,
                onTap: () => _makePhoneCall(_agency!.phone),
              ),
              if (_agency!.email != null)
                _buildInfoRow(
                  icon: Icons.email,
                  label: 'البريد الإلكتروني',
                  value: _agency!.email!,
                  onTap: () => _sendEmail(_agency!.email!),
                ),
              if (_agency!.website != null)
                _buildInfoRow(
                  icon: Icons.web,
                  label: 'الموقع الإلكتروني',
                  value: _agency!.website!,
                  onTap: () => _openWebsite(_agency!.website!),
                ),
            ],
          ),
          const SizedBox(height: 24),
          // Description
          if (_agency!.description != null)
            _buildInfoSection(
              title: 'نبذة عن الوكالة',
              icon: Icons.description,
              children: [
                Text(
                  _agency!.description!,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 24),
          // Specialties
          if (_agency!.specialties.isNotEmpty)
            _buildInfoSection(
              title: 'التخصصات',
              icon: Icons.category,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _agency!.specialties.map((specialty) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).primaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        specialty,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 14,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          const SizedBox(height: 24),
          // Working Hours
          if (_agency!.workingHours != null)
            _buildInfoSection(
              title: 'ساعات العمل',
              icon: Icons.access_time,
              children: [
                Text(
                  _formatWorkingHours(_agency!.workingHours!),
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 16,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildOffersTab() {
    if (_agency!.offers == null || _agency!.offers!.isEmpty) {
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
                'لا توجد عروض متاحة حالياً',
                style: TextStyle(
                  fontFamily: 'Tajawal',
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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _agency!.offers!.length,
      itemBuilder: (context, index) {
        final offer = _agency!.offers![index];
        return _buildOfferCard(offer);
      },
    );
  }

  Widget _buildReviewsTab() {
    if (_agency!.reviews == null || _agency!.reviews!.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star_outline,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'لا توجد تقييمات بعد',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'كن أول من يقيم هذه الوكالة',
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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _agency!.reviews!.length,
      itemBuilder: (context, index) {
        final review = _agency!.reviews![index];
        return _buildReviewCard(review);
      },
    );
  }

  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 12),
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
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 16,
                        color: onTap != null ? Theme.of(context).primaryColor : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey[400],
                ),
            ],
          ),
        ),
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
            // Header with title and featured badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    offer.title,
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (offer.isFeatured)
                  Container(
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
                          'مميز',
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
            // Destination and duration
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  offer.destination,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '${offer.durationDays} أيام',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            if (offer.description != null) ...[
              const SizedBox(height: 8),
              Text(
                offer.description!,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            // Price and category
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    offer.category ?? 'غير محدد',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 12,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${offer.priceDzd.toStringAsFixed(0)} دج',
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            if (offer.includes != null && offer.includes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'يشمل:',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              ...offer.includes!.take(3).map((include) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 14,
                        color: Colors.green[600],
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          include,
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              if (offer.includes!.length > 3)
                Text(
                  'و ${offer.includes!.length - 3} عناصر أخرى...',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(TravelAgencyReview review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with user info and rating
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: review.userAvatar != null
                      ? NetworkImage(review.userAvatar!)
                      : null,
                  child: review.userAvatar == null
                      ? Icon(
                          Icons.person,
                          color: Colors.grey[600],
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userName ?? 'مستخدم',
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              index < review.rating
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 16,
                              color: Colors.amber[600],
                            );
                          }),
                          const SizedBox(width: 8),
                          Text(
                            _formatDate(review.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (review.isVerified)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified,
                          size: 12,
                          color: Colors.green[600],
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'موثق',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 10,
                            color: Colors.green[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            if (review.title != null) ...[
              const SizedBox(height: 12),
              Text(
                review.title!,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            if (review.comment != null) ...[
              const SizedBox(height: 8),
              Text(
                review.comment!,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
            if (review.helpfulCount > 0) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.thumb_up,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${review.helpfulCount} شخص وجد هذا التقييم مفيداً',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _makePhoneCall(_agency!.phone),
              icon: const Icon(Icons.call),
              label: const Text(
                'اتصال',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _sendWhatsApp(_agency!.phone),
              icon: const Icon(Icons.message),
              label: const Text(
                'واتساب',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green,
                side: const BorderSide(color: Colors.green),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _makePhoneCall(String phoneNumber) async {
    try {
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      final uri = Uri.parse('tel:$cleanNumber');
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        // Fallback: copy to clipboard
        await Clipboard.setData(ClipboardData(text: cleanNumber));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم نسخ رقم الهاتف: $cleanNumber'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('خطأ في الاتصال'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _sendWhatsApp(String phoneNumber) async {
    try {
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      final message = Uri.encodeComponent('مرحباً، أريد الاستفسار عن خدماتكم السياحية');
      final uri = Uri.parse('https://wa.me/$cleanNumber?text=$message');
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('لا يمكن فتح واتساب'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('خطأ في إرسال رسالة واتساب'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _sendEmail(String email) async {
    try {
      final uri = Uri.parse('mailto:$email');
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        await Clipboard.setData(ClipboardData(text: email));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم نسخ البريد الإلكتروني: $email'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('خطأ في إرسال البريد الإلكتروني'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _openWebsite(String website) async {
    try {
      String url = website;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }
      
      final uri = Uri.parse(url);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await Clipboard.setData(ClipboardData(text: url));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم نسخ رابط الموقع: $url'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('خطأ في فتح الموقع'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'غير محدد';
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 30) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }

  String _formatWorkingHours(Map<String, dynamic> workingHours) {
    final List<String> formattedHours = [];
    
    workingHours.forEach((day, hours) {
      if (hours != null && hours.toString().isNotEmpty) {
        formattedHours.add('$day: $hours');
      }
    });
    
    return formattedHours.isNotEmpty ? formattedHours.join('\n') : 'غير محدد';
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverTabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}