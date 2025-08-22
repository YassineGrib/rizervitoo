import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rizervitoo/screens/sign_up_screen.dart';
import 'package:rizervitoo/screens/forgot_password_screen.dart';
import 'package:rizervitoo/screens/home_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      // Save login state if remember me is checked
      if (_rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('remember_login', true);
        await prefs.setString('user_email', _emailController.text.trim());
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تم تسجيل الدخول بنجاح',
              style: TextStyle(fontFamily: 'Tajawal'),
            ),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate to home screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
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
    if (error.contains('Invalid login credentials')) {
      return 'بيانات الدخول غير صحيحة';
    } else if (error.contains('Email not confirmed')) {
      return 'يرجى تأكيد البريد الإلكتروني أولاً';
    } else if (error.contains('Too many requests')) {
      return 'محاولات كثيرة، يرجى المحاولة لاحقاً';
    }
    return 'حدث خطأ في تسجيل الدخول';
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    
                    // Back Button
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios),
                        color: Colors.blue.shade600,
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
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
                    
                    const SizedBox(height: 32),
                    
                    // Title
                    Text(
                      'أهلاً بك مرة أخرى',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'سجل دخولك للمتابعة',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
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
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'يرجى إدخال بريد إلكتروني صحيح';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'كلمة المرور',
                        labelStyle: const TextStyle(
                          fontFamily: 'Tajawal',
                          color: Colors.grey,
                        ),
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
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
                          return 'يرجى إدخال كلمة المرور';
                        }
                        if (value.length < 6) {
                          return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Remember Me and Forgot Password Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Remember Me Checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                              activeColor: Colors.blue.shade600,
                            ),
                            Text(
                              'تذكرني',
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                color: Colors.grey.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        // Forgot Password
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'نسيت كلمة المرور؟',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              color: Colors.blue.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Sign In Button
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signIn,
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
                                'تسجيل الدخول',
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Sign Up Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ليس لديك حساب؟ ',
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
                                builder: (context) => const SignUpScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'إنشاء حساب',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              color: Colors.blue.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}