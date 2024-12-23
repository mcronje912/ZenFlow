// lib/main.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';

// Define our custom colors as constants
class ZenFlowColors {
  // Primary colors
  static const Color primaryDarkTeal = Color(0xFF042A2B);
  static const Color secondarySeaBlue = Color(0xFF5EB1BF);
  static const Color backgroundLightBlue = Color(0xFFCDEDF6);
  static const Color accentCoral = Color(0xFFEF7B45);
  static const Color errorBrickRed = Color(0xFFD84727);

  // Create lighter/darker variations for different states
  static const Color primaryLighter = Color(0xFF0A3F41);
  static const Color surfaceLight = Color(0xFFF5FAFC);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZenFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Use our custom color scheme
        colorScheme: ColorScheme(
          primary: ZenFlowColors.primaryDarkTeal,
          primaryContainer: ZenFlowColors.primaryLighter,
          secondary: ZenFlowColors.secondarySeaBlue,
          surface: ZenFlowColors.surfaceLight,
          background: ZenFlowColors.backgroundLightBlue,
          error: ZenFlowColors.errorBrickRed,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: ZenFlowColors.primaryDarkTeal,
          onBackground: ZenFlowColors.primaryDarkTeal,
          onError: Colors.white,
          brightness: Brightness.light,
        ),

        // Custom component themes
        appBarTheme: AppBarTheme(
          backgroundColor: ZenFlowColors.primaryDarkTeal,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            fontFamily: 'AdventPro',
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),

        // Cards theme
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        // Floating Action Button theme
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: ZenFlowColors.secondarySeaBlue,
          foregroundColor: Colors.white,
          elevation: 4,
        ),

        // Elevated Button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: ZenFlowColors.secondarySeaBlue,
            foregroundColor: Colors.white,
            elevation: 2,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontFamily: 'AdventPro',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),

        // Input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: ZenFlowColors.secondarySeaBlue),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: ZenFlowColors.primaryDarkTeal, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: ZenFlowColors.secondarySeaBlue),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: TextStyle(
            fontFamily: 'AdventPro',
            color: ZenFlowColors.primaryDarkTeal.withOpacity(0.8),
          ),
        ),

        // Text theme
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: ZenFlowColors.primaryDarkTeal,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.1,
            color: ZenFlowColors.primaryDarkTeal,
          ),
          labelLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: ZenFlowColors.primaryDarkTeal,
          ),
        ),
        
        fontFamily: 'AdventPro',
      ),
      home: FutureBuilder<bool>(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return snapshot.data == true ? const HomeScreen() : const LoginScreen();
        },
      ),
    );
  }

  Future<bool> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }
}