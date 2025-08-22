import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rizervitoo/screens/welcome_screen.dart';

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rizervitoo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
