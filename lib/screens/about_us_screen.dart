import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.blue.shade800,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'حول التطبيق',
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assest/images/logo_blue.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // App Name
            Text(
              'RizerVitoo',
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // App Tagline
            Text(
              'تطبيق الحجوزات السياحية الجزائري',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // About Section
            _buildSection(
              title: 'من نحن',
              content: 'RizerVitoo هو تطبيق سياحي جزائري مبتكر يهدف إلى تسهيل عملية حجز الإقامات السياحية في جميع أنحاء الجزائر. نحن نربط بين المسافرين وأصحاب العقارات السياحية لتوفير تجربة سفر مميزة وآمنة.',
              icon: Icons.info_outline,
            ),
            
            const SizedBox(height: 24),
            
            // Mission Section
            _buildSection(
              title: 'رسالتنا',
              content: 'نسعى لتعزيز السياحة الداخلية في الجزائر من خلال توفير منصة رقمية سهلة الاستخدام تمكن المسافرين من اكتشاف أجمل الوجهات السياحية والحصول على أفضل الإقامات بأسعار مناسبة.',
              icon: Icons.flag_outlined,
            ),
            
            const SizedBox(height: 24),
            
            // Features Section
            _buildSection(
              title: 'خدماتنا',
              content: '• حجز الإقامات السياحية (فنادق، منازل، مراقد)\n• دليل سياحي شامل للوجهات الجزائرية\n• خدمات الوكالات السياحية\n• مرشدين سياحيين محليين\n• نظام تقييم ومراجعات موثوق\n• دعم فني على مدار الساعة',
              icon: Icons.star_outline,
            ),
            
            const SizedBox(height: 24),
            
            // Vision Section
            _buildSection(
              title: 'رؤيتنا',
              content: 'أن نكون المنصة الرائدة للسياحة الداخلية في الجزائر، ونساهم في تطوير القطاع السياحي من خلال التكنولوجيا الحديثة والخدمات المتميزة.',
              icon: Icons.visibility_outlined,
            ),
            
            const SizedBox(height: 32),
            
            // Contact Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade50, Colors.blue.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.contact_support_outlined,
                    size: 40,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'تواصل معنا',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'لأي استفسارات أو اقتراحات، نحن هنا لمساعدتك',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildContactButton(
                        icon: Icons.email_outlined,
                        label: 'البريد الإلكتروني',
                        onTap: () {
                          // TODO: Open email app
                        },
                      ),
                      _buildContactButton(
                        icon: Icons.phone_outlined,
                        label: 'الهاتف',
                        onTap: () {
                          // TODO: Make phone call
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Version Info
            Text(
              'الإصدار 1.0.0',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 12,
                color: Colors.grey.shade400,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              '© 2025 RizerVitoo. جميع الحقوق محفوظة',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 12,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSection({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.blue.shade700,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 16,
              color: Colors.black87,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: Colors.blue.shade700,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 12,
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}