import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_scraping_with_flutter/core/services/cache_service.dart';
import 'package:web_scraping_with_flutter/core/theme/app_theme.dart';
import 'package:web_scraping_with_flutter/features/providers/news_providers.dart';
import 'package:web_scraping_with_flutter/homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize cache
  await cacheService.init();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BD News Hub',
      theme: buildAppTheme(ThemeMode.light),
      darkTheme: buildAppTheme(ThemeMode.dark),
      themeMode: themeMode,
      home: const HomePage(),
    );
  }
}

