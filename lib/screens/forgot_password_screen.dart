import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rizervitoo/screens/sign_in_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        _emailController.text.trim(),
        redirectTo: 'io.supabase.rizervitoo://reset-password',
      );
      
      if (mounted) {
        setState(() {
          _emailSent = true;
        });
      }
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _getErrorMessage(error.message),
              style: const TextStyle(fontFamily: 'Tajawal'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'حدث خطأ غير متوقع',
              style: TextStyle(fontFamily: 'Tajawal'),
            ),
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

  String _getErrorMessage(String error) {
    if (error.contains('Invalid email')) {
      return 'البريد الإلكتروني غير صحيح';
    } else if (error.contains('User not found')) {
      return 'لا يوجد حساب مرتبط بهذا البريد الإلكتروني';
    }
    return 'حدث خطأ في إرسال رابط إعادة تعيين كلمة المرور';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.shade50,
                Colors.white,
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  
                  // Back Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios),
                      color: Colors.blue.shade600,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Logo
                  Center(
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: Image.asset(
                        'assest/images/logo_black.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  if (!_emailSent) ..._buildResetForm() else ..._buildSuccessMessage(),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildResetForm() {
    return [
      // Title
      Text(
        'نسيت كلمة المرور؟',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Amiri',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade800,
        ),
      ),
      
      const SizedBox(height: 12),
      
      Text(
        'لا تقلق، سنرسل لك رابط إعادة تعيين كلمة المرور',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Tajawal',
          fontSize: 16,
          color: Colors.grey.shade600,
          height: 1.5,
        ),
      ),
      
      const SizedBox(height: 40),
      
      // Illustration
      Center(
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(60),
          ),
          child: Icon(
            Icons.lock_reset,
            size: 60,
            color: Colors.blue.shade600,
          ),
        ),
      ),
      
      const SizedBox(height: 40),
      
      // Form
      Form(
        key: _formKey,
        child: Column(
          children: [
            // Email Field
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(
                labelText: 'البريد الإلكتروني',
                labelStyle: const TextStyle(
                  fontFamily: 'Tajawal',
                  color: Colors.grey,
                ),
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال البريد الإلكتروني';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}\$').hasMatch(value)) {
                  return 'يرجى إدخال بريد إلكتروني صحيح';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 32),
            
            // Reset Button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _resetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'إرسال رابط إعادة التعيين',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
      
      const SizedBox(height: 32),
      
      // Back to Sign In
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'تذكرت كلمة المرور؟ ',
            style: TextStyle(
              fontFamily: 'Tajawal',
              color: Colors.grey.shade600,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const SignInScreen(),
                ),
              );
            },
            child: Text(
              'تسجيل الدخول',
              style: TextStyle(
                fontFamily: 'Tajawal',
                color: Colors.blue.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildSuccessMessage() {
    return [
      // Success Icon
      Center(
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(60),
          ),
          child: Icon(
            Icons.check_circle_outline,
            size: 60,
            color: Colors.green.shade600,
          ),
        ),
      ),
      
      const SizedBox(height: 32),
      
      // Success Title
      Text(
        'تم إرسال الرابط!',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Amiri',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.green.shade800,
        ),
      ),
      
      const SizedBox(height: 16),
      
      // Success Message
      Text(
        'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني. يرجى التحقق من صندوق الوارد وصندوق الرسائل غير المرغوب فيها.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Tajawal',
          fontSize: 16,
          color: Colors.grey.shade600,
          height: 1.6,
        ),
      ),
      
      const SizedBox(height: 40),
      
      // Resend Button
      OutlinedButton(
        onPressed: () {
          setState(() {
            _emailSent = false;
          });
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.blue.shade600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
        child: Text(
          'إرسال مرة أخرى',
          style: TextStyle(
            fontFamily: 'Tajawal',
            color: Colors.blue.shade600,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      const SizedBox(height: 16),
      
      // Back to Sign In
      TextButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const SignInScreen(),
            ),
          );
        },
        child: Text(
          'العودة إلى تسجيل الدخول',
          style: TextStyle(
            fontFamily: 'Tajawal',
            color: Colors.blue.shade600,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ];
  }
}