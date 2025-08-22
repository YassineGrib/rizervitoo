import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rizervitoo/screens/welcome_screen.dart';
import 'package:rizervitoo/screens/home_screen.dart';
import 'package:rizervitoo/screens/admin_login_screen.dart';
import 'package:rizervitoo/screens/admin_dashboard_screen.dart';
import 'package:rizervitoo/screens/admin_travel_guides_screen.dart';
import 'package:rizervitoo/screens/admin_travel_guide_form_screen.dart';
import 'package:rizervitoo/screens/admin_users_screen.dart';

// Get a reference to the Supabase client
final supabase = Supabase.instance.client;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://zmleqfnqkdgsbaftfmau.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InptbGVxZm5xa2Rnc2JhZnRmbWF1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU4MDMyMDcsImV4cCI6MjA3MTM3OTIwN30.3qx5-CfiI9WzJujpnB2J_RKTvpI-o47Zp9E03nItqAQ',
  );
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberLogin = prefs.getBool('remember_login') ?? false;
      
      if (rememberLogin) {
        // Check if user session is still valid
        final session = supabase.auth.currentSession;
        if (session != null) {
          setState(() {
            _isLoggedIn = true;
            _isLoading = false;
          });
          return;
        } else {
          // Clear saved login state if session is invalid
          await prefs.remove('remember_login');
          await prefs.remove('user_email');
        }
      }
    } catch (e) {
      // Handle any errors silently
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rizervitoo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // Force RTL layout
      locale: const Locale('ar', 'DZ'), // Arabic (Algeria)
      supportedLocales: const [
        Locale('ar', 'DZ'), // Arabic (Algeria)
        Locale('en', 'US'), // English (fallback)
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      routes: {
        '/': (context) => _isLoading
            ? const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : _isLoggedIn
                ? const HomeScreen()
                : const WelcomeScreen(),
        '/admin-login': (context) => const AdminLoginScreen(),
        '/admin-dashboard': (context) => const AdminDashboardScreen(),
        '/admin-travel-guides': (context) => const AdminTravelGuidesScreen(),
        '/admin-users': (context) => const AdminUsersScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/admin-travel-guide-form') {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => AdminTravelGuideFormScreen(
              guide: args?['guide'],
            ),
          );
        }
        return null;
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
