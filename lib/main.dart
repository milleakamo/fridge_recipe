import 'package:flutter/material.dart';
import 'package:fridge_recipe/screens/main_navigation_screen.dart';
import 'package:fridge_recipe/models/ingredient.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(IngredientAdapter());
  }
  await Hive.openBox<Ingredient>('ingredients');
  
  runApp(const MyApp(apiKey: 'YOUR_YOUTUBE_API_KEY'));
}

class MyApp extends StatelessWidget {
  final String apiKey;

  const MyApp({Key? key, required this.apiKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fridge Recipe',
      theme: ThemeData(
        fontFamily: 'Pretendard',
        primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
      ),
      debugShowCheckedModeBanner: false,
      home: const VersionInfoOverlay(child: MainNavigationScreen(apiKey: 'YOUR_YOUTUBE_API_KEY')),
    );
  }
}

class VersionInfoOverlay extends StatelessWidget {
  final Widget child;
  const VersionInfoOverlay({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          top: 0,
          right: 0,
          child: SafeArea(
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(8)),
                ),
                child: const Text(
                  'v1.3.0 Stable 🦞',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
