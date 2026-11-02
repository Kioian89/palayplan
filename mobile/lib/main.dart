import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/language_provider.dart';
import 'providers/field_provider.dart';
import 'screens/splash_screen.dart';
import 'services/api_service.dart';
import 'services/firebase_auth_service.dart';
import 'services/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseAuthService? authService;
  final firebaseOptions = FirebaseClientOptions.current;
  if (firebaseOptions != null) {
    try {
      await Firebase.initializeApp(options: firebaseOptions);
      authService = FirebaseAuthService(
        auth: FirebaseAuth.instance,
        api: ApiService(),
      );
    } catch (e) {
      debugPrint('Firebase initialization error: $e');
    }
  }

  runApp(PalayPlanApp(authService: authService));
}

class PalayPlanApp extends StatelessWidget {
  const PalayPlanApp({super.key, this.authService});

  final FirebaseAuthService? authService;

  @override
  Widget build(BuildContext context) {
    const primaryAccent = Color(0xFFFF7E55);
    const deepSlate = Color(0xFF191D24);
    const surfaceCream = Color(0xFFF8F6F2);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => FieldProvider()),
      ],
      child: Consumer2<LanguageProvider, FieldProvider>(
        builder: (context, _, __, ___) {
          return MaterialApp(
            title: 'PalayPlan',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              scaffoldBackgroundColor: surfaceCream,
              colorScheme: ColorScheme.fromSeed(
                seedColor: primaryAccent,
                primary: primaryAccent,
                secondary: const Color(0xFF2E7D32),
                surface: Colors.white,
                onSurface: const Color(0xFF192024),
              ),
              appBarTheme: const AppBarTheme(
                elevation: 0,
                scrolledUnderElevation: 0,
                backgroundColor: surfaceCream,
                foregroundColor: deepSlate,
                centerTitle: false,
                titleTextStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: deepSlate,
                  letterSpacing: -0.3,
                ),
              ),
              cardTheme: CardThemeData(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: primaryAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryAccent,
                  side: const BorderSide(color: Color(0xFFFFCCBC), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              textTheme: const TextTheme(
                headlineMedium: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF12342E),
                  letterSpacing: -0.5,
                ),
                titleLarge: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B3B36),
                  letterSpacing: -0.2,
                ),
                titleMedium: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C4A45),
                ),
                bodyLarge: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF2D3748),
                  height: 1.4,
                ),
                bodyMedium: TextStyle(
                  fontSize: 14.5,
                  color: Color(0xFF4A5568),
                  height: 1.35,
                ),
              ),
            ),
            home: SplashScreen(authService: authService),
          );
        },
      ),
    );
  }
}
