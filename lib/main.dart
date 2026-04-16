import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'analytics/analytics_manager.dart';
import 'firebase_options.dart';
import 'models/product.dart';
import 'screens/cart_screen.dart';
import 'screens/home_screen.dart';
import 'screens/product_screen.dart';
import 'screens/success_screen.dart';
import 'services/cart_service.dart';
import 'services/order_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Inicializa Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartService()),
        Provider(create: (_) => OrderRepository()),
      ],
      child: const EcommerceApp(),
    ),
  );
}

// ─────────────────────────────────────────
// Router
// ─────────────────────────────────────────
final _router = GoRouter(
  initialLocation: '/home',
  observers: [AnalyticsManager.routeObserver],
  routes: [
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/product/:productId',
      name: 'product',
      builder: (context, state) {
        final productId = state.pathParameters['productId']!;
        final extra = state.extra as Map<String, dynamic>?;
        return ProductScreen(
          productId: productId,
          listId: extra?['listId'] as String? ?? 'destaque-home',
          listName: extra?['listName'] as String? ?? 'Destaque Home',
          index: extra?['index'] as int? ?? 0,
        );
      },
    ),
    GoRoute(
      path: '/cart',
      name: 'cart',
      builder: (context, state) => const CartScreen(),
    ),
    GoRoute(
      path: '/success/:orderId',
      name: 'success',
      builder: (context, state) {
        final orderId = state.pathParameters['orderId']!;
        return SuccessScreen(orderId: orderId);
      },
    ),
  ],
);

// ─────────────────────────────────────────
// App Root
// ─────────────────────────────────────────
class EcommerceApp extends StatelessWidget {
  const EcommerceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TechStore',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      routerConfig: _router,
    );
  }

  ThemeData _buildTheme() {
    const primaryColor = Color(0xFFFF9400);
    const backgroundColor = Color(0xFF1A1A21);
    const surfaceColor = Color(0xFF242430);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: primaryColor,
        surface: surfaceColor,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardTheme(
        color: surfaceColor,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C3A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryColor),
        ),
        labelStyle: const TextStyle(color: Colors.grey),
        hintStyle: const TextStyle(color: Colors.grey),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceColor,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
