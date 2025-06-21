import 'package:flutter/material.dart';
import 'package:priem_poliklinika/func/supabase_connect.dart';
import 'package:priem_poliklinika/pages/board_page/onboarding_page.dart';
import 'package:priem_poliklinika/pages/main_pages/choose_menu.dart';
import 'package:priem_poliklinika/pages/main_pages/navbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initSupabase();
  runApp(MyApp());
}

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.white,
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: Colors.blue,
    secondary: Colors.blueAccent,
    surface: Colors.white,
  ),
  fontFamily: 'Roboto',
);
String? profilePagePath;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: lightTheme,
      home: FutureBuilder(
        future: checkAuthStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !(snapshot.data ?? false)) {
            return const OnboardingPage();
          } else {
            return FutureBuilder<String>(
              future: get_profile_page_path(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(
                      child: Text('Error loading profile page path'));
                } else {
                  return MainBottomNavBar();
                }
              },
            );
          }
        },
      ),
    );
  }
}

Future<bool> checkAuthStatus() async {
  final session = Supabase.instance.client.auth.currentSession;
  if (session != null) {
    return true;
  }
  return false;
}

// ignore: non_constant_identifier_names
Future<String> get_profile_page_path() async {
  if (supabase.auth.currentSession != null) {
    final response = await Supabase.instance.client
        .from('user')
        .select('profile_page_path')
        .eq('uuid', supabase.auth.currentUser!.id)
        .order('profile_page_path', ascending: true)
        .limit(1)
        .single();
    return response['profile_page_path'] as String;
  }
  return "None.png";
}
