
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'pages/dashboard_page.dart';
import 'pages/login_page.dart';

const forestGreen = Color(0xFF285943);
const sageGreen = Color(0xFF91A98A);
const botanicalCream = Color(0xFFF6F4EA);
const leafGold = Color(0xFFC5A66A);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const PlantNurseryApp());
}

class PlantNurseryApp extends StatelessWidget {
  const PlantNurseryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plant Nursery',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: botanicalCream,

        colorScheme: const ColorScheme.light(
          primary: forestGreen,
          onPrimary: Colors.white,
          secondary: sageGreen,
          onSecondary: forestGreen,
          surface: botanicalCream,
          onSurface: forestGreen,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: forestGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),

        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: sageGreen),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          labelStyle: const TextStyle(color: forestGreen),
          prefixIconColor: sageGreen,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: sageGreen),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: sageGreen),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: forestGreen,
              width: 2,
            ),
          ),
        ),

        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: forestGreen,
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: forestGreen,
            side: const BorderSide(color: sageGreen),
            minimumSize: const Size(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),

        floatingActionButtonTheme:
            const FloatingActionButtonThemeData(
          backgroundColor: forestGreen,
          foregroundColor: Colors.white,
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

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return Scaffold(
        backgroundColor: botanicalCream,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/app_logo.png',
                width: 125,
                height: 125,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 24),

              const Text(
                'Plant Nursery',
                style: TextStyle(
                  color: forestGreen,
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'BOTANICAL CARE TRACKER',
                style: TextStyle(
                  color: sageGreen,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 35),

              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: forestGreen,
                  backgroundColor: sageGreen,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'GROW WITH NATURE',
                style: TextStyle(
                  color: forestGreen,
                  fontSize: 10,
                  letterSpacing: 1.5,
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
            backgroundColor: botanicalCream,
            body: Center(
              child: CircularProgressIndicator(
                color: forestGreen,
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
