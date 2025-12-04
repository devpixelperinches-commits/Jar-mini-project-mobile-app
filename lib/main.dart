import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/router.dart';

Future<void> main() async {
  // Needed for splash to work properly
  final WidgetsBinding binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  // Load env (optional in production builds using --dart-define)
  await _loadEnvironment();

  // ⏳ (Optional) Add any initialization delays here
  await Future.delayed(const Duration(milliseconds: 800));

  // Remove splash screen
  FlutterNativeSplash.remove();

  runApp(const ProviderScope(child: MyApp()));
}

Future<void> _loadEnvironment() async {
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('dotenv file not bundled, relying on dart-define values. $e');
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      showPerformanceOverlay: false,
      routerConfig: router,
    );
  }
}
