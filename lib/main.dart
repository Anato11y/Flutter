import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'providers/products_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/cart_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyCTaCKO5EKvogHzz4she8SMmmjWPG1A70Q',
      appId: '1:569239102195:web:0d2f70c3bafc47a6774d86',
      messagingSenderId: '569239102195',
      projectId: 'onlineshop-d6001',
      authDomain: 'onlineshop-d6001.firebaseapp.com',
      storageBucket: 'onlineshop-d6001.appspot.com',
      measurementId: 'G-MCC5PDY5GJ',
    ),
  );

  // Используем Firestore Emulator только в режиме отладки
  if (!kReleaseMode) {
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  }

  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductsProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Магазин водяных фильтров',
        theme: _buildAppTheme(),
        darkTheme: _buildDarkAppTheme(), // Добавляем темную тему
        themeMode: ThemeMode.system, // Автоматическое переключение темы
        home: FutureBuilder<Widget>(
          future: InitialScreenDetermination(prefs).determineInitialScreen(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingScreen(context);
            }
            if (snapshot.hasError) {
              return _buildErrorScreen(context, snapshot.error!);
            }
            return snapshot.data ??
                const SizedBox.shrink(); // Безопасное значение по умолчанию
          },
        ),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/cart': (context) => const CartScreen(),
          '/auth': (context) => const AuthScreen(),
        },
      ),
    );
  }

  ThemeData _buildAppTheme() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF00B4D8),
        primary: const Color(0xFF0096C7),
        secondary: const Color(0xFF48CAE4),
        tertiary: const Color(0xFF90E0EF),
        surface: const Color(0xFFF0F8FF),
        brightness: Brightness.light,
      ),
      fontFamily: 'Inter',
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.grey[900],
        ),
        iconTheme: const IconThemeData(color: Color(0xFF006D77)),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: const Color(0xFF00B4D8),
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shadowColor: const Color(0x400096C7),
          elevation: 4,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
        shadowColor: const Color(0x20006D77),
      ),
    );
  }

  ThemeData _buildDarkAppTheme() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.black,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF00B4D8),
        primary: const Color(0xFF0096C7),
        secondary: const Color(0xFF48CAE4),
        tertiary: const Color(0xFF90E0EF),
        surface: const Color(0xFF121212),
        brightness: Brightness.dark,
      ),
      fontFamily: 'Inter',
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Color(0xFF006D77)),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: const Color(0xFF00B4D8),
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shadowColor: const Color(0x400096C7),
          elevation: 4,
        ),
      ),
    );
  }

  Widget _buildLoadingScreen(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Animate(
              effects: [
                ScaleEffect(duration: 800.ms),
                ShimmerEffect(delay: 300.ms)
              ],
              child: Icon(
                Icons.water_drop_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Загрузка приложения...',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(0xCC),
                fontSize: 16,
              ),
            ).animate(onPlay: (controller) => controller.repeat()).shimmer(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, Object error) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Animate(
                effects: [ShakeEffect(duration: 900.ms)],
                child: Icon(
                  Icons.error_outline_rounded,
                  color: Theme.of(context).colorScheme.error,
                  size: 56,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Ошибка инициализации',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ).animate().fadeIn(),
              const SizedBox(height: 16),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withAlpha(0x99),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Попробовать снова'),
                onPressed: () => main(),
              ).animate().scale(),
            ],
          ),
        ),
      ),
    );
  }
}

class InitialScreenDetermination {
  final SharedPreferences prefs;

  InitialScreenDetermination(this.prefs);

  Future<Widget> determineInitialScreen() async {
    bool onboardingCompleted = prefs.getBool('onboardingComplete') ?? false;
    return onboardingCompleted ? const HomeScreen() : const OnboardingScreen();
  }
}
