/// Student Numbers: [ADD YOUR STUDENT NUMBERS HERE]
/// Student Names  : [ADD YOUR FULL NAMES HERE]
/// Question: Main Entry Point - App Initialization
library;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'providers/auth_provider.dart';
import 'providers/application_provider.dart';
import 'views/auth/login_screen.dart';
import 'views/student/home_screen.dart';
import 'views/admin/admin_dashboard_screen.dart';
import 'utils/app_theme.dart';
import 'utils/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://cvuczksuaslsntnfmhxp.supabase.co',           // Replace with your Supabase project URL
    anonKey: 'sb_publishable_5jSzBVCCpyvlAwlUwLSlNw_oFb9KQGi',  // Replace with your Supabase anon key
  );

  runApp(const StudentAssistantApp());
}

class StudentAssistantApp extends StatelessWidget {
  const StudentAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, ApplicationProvider>(
          create: (_) => ApplicationProvider(),
          update: (_, auth, prev) => prev!..updateAuth(auth),
        ),
      ],
      child: MaterialApp(
        title: 'SA Apply — CUT IT Department',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        onGenerateRoute: AppRoutes.generateRoute,
        home: const AppEntryPoint(),
      ),
    );
  }
}

/// Decides which screen to show based on auth state
class AppEntryPoint extends StatelessWidget {
  const AppEntryPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isLoading) {
          return const SplashScreen();
        }
        if (!auth.isAuthenticated) {
          return const LoginScreen();
        }
        if (auth.isAdmin) {
          return const AdminDashboardScreen();
        }
        return const HomeScreen();
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDeep,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.accentGold,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.school_rounded, size: 48, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              'SA Apply',
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 32,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'CUT Information Technology',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: Colors.white54,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentGold),
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}

