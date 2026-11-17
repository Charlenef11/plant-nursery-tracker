import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'pages/dashboard_page.dart';
import 'pages/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const StudentInformationApp());
}

class StudentInformationApp extends StatelessWidget {
  const StudentInformationApp({super.key});

  @override
  Widget build(BuildContext context) {
    const deepTeal = Color(0xFF164E52);
    const champagne = Color(0xFFC9A875);
    const cream = Color(0xFFF5F2E9);

    return MaterialApp(
      title: 'Student Information App',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: cream,

        colorScheme: const ColorScheme.light(
          primary: deepTeal,
          onPrimary: cream,
          secondary: champagne,
          onSecondary: deepTeal,
          surface: cream,
          onSurface: deepTeal,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: deepTeal,
          foregroundColor: cream,
          elevation: 0,
          centerTitle: false,
        ),

        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: champagne),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          labelStyle: const TextStyle(color: deepTeal),
          prefixIconColor: champagne,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: champagne),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: champagne),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: deepTeal,
              width: 2,
            ),
          ),
        ),

        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: deepTeal,
            foregroundColor: cream,
            minimumSize: const Size(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: deepTeal,
            side: const BorderSide(color: champagne),
            minimumSize: const Size(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),

        floatingActionButtonTheme:
            const FloatingActionButtonThemeData(
          backgroundColor: deepTeal,
          foregroundColor: cream,
        ),
      ),

      home: const AppSplashGate(),
    );
  }
}

class AppSplashGate extends StatefulWidget {
  const AppSplashGate({super.key});

  @override
  State<AppSplashGate> createState() => _AppSplashGateState();
}

class _AppSplashGateState extends State<AppSplashGate> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const deepTeal = Color(0xFF164E52);
    const champagne = Color(0xFFC9A875);
    const cream = Color(0xFFF5F2E9);

    if (_showSplash) {
      return Scaffold(
        backgroundColor: cream,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 160,
                height: 160,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: champagne,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: deepTeal.withValues(alpha: 0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/app_logo.png',
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Student Information App',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: deepTeal,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Manage student records with ease',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: deepTeal,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 35),

              const SizedBox(
                width: 130,
                child: LinearProgressIndicator(
                  backgroundColor: champagne,
                  color: deepTeal,
                  minHeight: 4,
                ),
              ),

              const SizedBox(height: 14),

              const Text(
                'Loading...',
                style: TextStyle(
                  color: deepTeal,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: cream,
            body: Center(
              child: CircularProgressIndicator(
                color: deepTeal,
              ),
            ),
          );
        }

        return snapshot.hasData
            ? const DashboardPage()
            : const LoginPage();
      },
    );
  }
}
