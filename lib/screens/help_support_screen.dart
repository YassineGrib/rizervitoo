import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_styles.dart';
import '../models/booking_status.dart';
import '../models/payment_status.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

// Fix the TextDirection issue
import 'dart:ui' as ui;

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text(
            'المساعدة والدعم',
            style: AppStyles.appBarTitleStyle,
            textAlign: TextAlign.center,
          ),
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppStyles.darkPrimaryColor
              : AppStyles.primaryColor,
          elevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // FAQ Section
                  _buildSectionCard(
                    context,
                    title: 'الأسئلة الشائعة',
                    icon: Icons.question_answer,
                    children: [
                      _buildFAQItem(
                        context,
                        'كيف أقوم بحجز إقامة؟',
                        'للحجز، ابحث عن الإقامة التي تريدها، اختر تواريخ الحجز، واملأ معلومات الضيوف، ثم اضغط على "احجز الآن".',
                      ),
                      _buildFAQItem(
                        context,
                        'ما هي سياسة الإلغاء؟',
                        'تختلف سياسة الإلغاء حسب نوع الحجز وسياسة المضيف. تظهر تفاصيل سياسة الإلغاء قبل تأكيد الحجز.',
                      ),
                      _buildFAQItem(
                        context,
                        'كيف أضيف تقييم لإقامة؟',
                        'بعد إكمال الحجز، يمكنك إضافة تقييم من خلال صفحة الحجوزات الخاصة بك.',
                      ),
                      _buildFAQItem(
                        context,
                        'كيف أتواصل مع المضيف؟',
                        'يمكنك استخدام نموذج التواصل في صفحة الإقامة أو من خلال صفحة الرسائل في حسابك.',
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Contact Support Section
                  _buildSectionCard(
                    context,
                    title: 'اتصل بالدعم',
                    icon: Icons.support_agent,
                    children: [
                      _buildContactItem(
                        context,
                        Icons.email,
                        'البريد الإلكتروني',
                        'support@rizervitoo.com',
                        () => _launchEmail(context),
                      ),
                      _buildContactItem(
                        context,
                        Icons.phone,
                        'رقم الهاتف',
                        '+213 555 555 555',
                        () => _launchPhone(context),
                      ),
                      _buildContactItem(
                        context,
                        Icons.chat_bubble_outline,
                        'الدردشة المباشرة',
                        'متوفرة من 9 صباحاً إلى 5 مساءً',
                        () => _launchChat(context),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Help Resources Section
                  // _buildSectionCard(
                  //   context,
                  //   title: 'مصادر المساعدة',
                  //   icon: Icons.school,
                  //   children: [
                  //     _buildResourceItem(
                  //       context,
                  //       Icons.book,
                  //       'الدليل الكامل للاستخدام',
                  //       'تعليمات مفصلة حول كيفية استخدام جميع ميزات التطبيق.',
                  //       () => _openGuide(context),
                  //     ),
                  //     _buildResourceItem(
                  //       context,
                  //       Icons.policy,
                  //       'سياسات الموقع',
                  //       'تفاصيل سياسات الخصوصية، الإلغاء، والشروط والأحكام.',
                  //       () => _openPolicies(context),
                  //     ),
                  //     _buildResourceItem(
                  //       context,
                  //       Icons.chat,
                  //       'مدونة المساعدة',
                  //       'نصائح واستراتيجيات لتحسين تجربة استخدام التطبيق.',
                  //       () => _openBlog(context),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, {required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppStyles.darkPrimaryColor.withOpacity(0.1)
                  : AppStyles.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppStyles.darkPrimaryColor
                      : AppStyles.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppStyles.darkPrimaryColor
                        : AppStyles.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: children,
          ),
        ],
      ),
    );
  }
}

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: TextStyle(
          fontFamily: 'Tajawal',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            answer,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
      iconColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildContactItem(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppStyles.darkPrimaryColor
                  : AppStyles.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceItem(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppStyles.darkPrimaryColor
                  : AppStyles.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ],
        ),
      ),
    );
  }

  void _launchEmail(BuildContext context) {
    // TODO: Implement email launching functionality
    _showComingSoonDialog(context, 'البريد الإلكتروني');
  }

  void _launchPhone(BuildContext context) {
    // TODO: Implement phone calling functionality
    _showComingSoonDialog(context, 'المكالمات الهاتفية');
  }

  void _launchChat(BuildContext context) {
    // TODO: Implement live chat functionality
    _showComingSoonDialog(context, 'الدردشة المباشرة');
  }

  void _openGuide(BuildContext context) {
    // TODO: Implement guide viewing functionality
    _showComingSoonDialog(context, 'الدليل الكامل للاستخدام');
  }

  void _openPolicies(BuildContext context) {
    // TODO: Implement policies viewing functionality
    _showComingSoonDialog(context, 'سياسات الموقع');
  }

  void _openBlog(BuildContext context) {
    // TODO: Implement blog viewing functionality
    _showComingSoonDialog(context, 'مدونة المساعدة');
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'قريباً',
          style: TextStyle(fontFamily: 'Amiri'),
        ),
        content: Text(
          'ميزة "$feature" ستكون متاحة في التحديث القادم.',
          style: const TextStyle(fontFamily: 'Tajawal'),
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text(
              'حسناً',
              style: TextStyle(fontFamily: 'Tajawal'),
            ),
          ),
        ],
      ),
    );
  }