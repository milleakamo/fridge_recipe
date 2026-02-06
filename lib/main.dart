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
      home: MainNavigationScreen(apiKey: apiKey),
    );
  }
}
