import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_scraping_with_flutter/core/theme/app_theme.dart';
import 'package:web_scraping_with_flutter/homepage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BD News Hub',
      theme: buildAppTheme(),
      home: const HomePage(),
    );
  }
}

