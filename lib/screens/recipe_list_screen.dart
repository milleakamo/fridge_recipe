import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/ingredient.dart';
import '../services/youtube_service.dart';
import 'package:url_launcher/url_launcher.dart';

class RecipeListScreen extends StatefulWidget {
  final List<Ingredient> ingredients;
  final String apiKey;

  const RecipeListScreen({Key? key, required this.ingredients, required this.apiKey}) : super(key: key);

  @override
  _RecipeListScreenState createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  late YouTubeService _youtubeService;
  late Future<List<Map<String, dynamic>>> _recipesFuture;

  @override
  void initState() {
    super.initState();
    _youtubeService = YouTubeService(widget.apiKey);
    _recipesFuture = _youtubeService.searchRecipes(widget.ingredients);
  }

  Future<void> _launchUrl(String videoId) async {
    final url = Uri.parse('https://www.youtube.com/watch?v=$videoId');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('오늘의 레시피 매거진', 
          style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w900, fontSize: 20)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _recipesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('에러 발생: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('추천 레시피가 없습니다.'));
          }

          final recipes = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 24),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return _buildMagazineCard(recipe, index);
            },
          );
        },
      ),
    );
  }

  Widget _buildMagazineCard(Map<String, dynamic> recipe, int index) {
    // 가상의 매칭률 계산
    final matchRate = (80 + (index * 7) % 20);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _launchUrl(recipe['id']),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  recipe['thumbnail'].replaceAll('default', 'mqdefault'), // 고해상도 시도
                  width: double.infinity,
                  height: 240,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '매칭률 $matchRate%',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe['channelTitle'],
                    style: const TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    recipe['title'],
                    style: const TextStyle(
                      fontSize: 22, 
                      fontWeight: FontWeight.w900, 
                      color: Color(0xFF111827),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "이 레시피를 따라하면 버려질 위기의 재료를 구할 수 있어요. ✨",
                    style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 18, color: Color(0xFF9CA3AF)),
                      const SizedBox(width: 4),
                      const Text('15분', style: TextStyle(color: Color(0xFF6B7280))),
                      const SizedBox(width: 16),
                      const Icon(Icons.bar_chart, size: 18, color: Color(0xFF9CA3AF)),
                      const SizedBox(width: 4),
                      const Text('쉬움', style: TextStyle(color: Color(0xFF6B7280))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: (index * 100).ms).slideY(begin: 0.1);
  }
}
