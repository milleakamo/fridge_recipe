import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fridge_recipe/models/ingredient.dart';
import 'package:fridge_recipe/services/diet_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DietScreen extends StatefulWidget {
  const DietScreen({Key? key}) : super(key: key);

  @override
  _DietScreenState createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  final DietService _dietService = DietService();
  Map<String, dynamic>? _dietPlan;
  bool _isLoading = false;

  Future<void> _generateDietPlan() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final ingredientBox = Hive.box<Ingredient>('ingredients');
      final ingredients = ingredientBox.values.toList();
      final dietPlan = await _dietService.generateDietPlan(ingredients);
      setState(() {
        _dietPlan = dietPlan;
      });
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('AI 맞춤 식단', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: Colors.black),
            onPressed: _generateDietPlan,
            tooltip: '식단 생성',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _dietPlan == null
              ? Center(
                  child: ElevatedButton(
                    onPressed: _generateDietPlan,
                    child: const Text('AI 식단 생성하기'),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDietGoalHeader(),
                      _buildTodayMeals(),
                      _buildUpcomingPlan(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
    );
  }

  Widget _buildDietGoalHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('현재 식단 목표', style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('균형 잡힌 일반식', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('진행 중', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const LinearProgressIndicator(
            value: 0.7,
            backgroundColor: Color(0xFFE5E7EB),
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
          ),
          const SizedBox(height: 8),
          const Text('오늘 하루 목표의 70% 달성!', style: TextStyle(fontSize: 12, color: Colors.blueAccent)),
        ],
      ),
    ).animate().fadeIn().slideX(begin: -0.1);
  }

  Widget _buildTodayMeals() {
    final today = _dietPlan!['diet_plan'][0];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Text('오늘의 AI 추천 식단', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        _buildMealItem('아침', today['meals']['breakfast']['menu'], today['meals']['breakfast']['reason'], true),
        _buildMealItem('점심', today['meals']['lunch']['menu'], today['meals']['lunch']['reason'], true),
        _buildMealItem('저녁', today['meals']['dinner']['menu'], today['meals']['dinner']['reason'], false),
      ],
    );
  }

  Widget _buildMealItem(String time, String menu, String reason, bool isDone) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDone ? Colors.blueAccent.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDone ? Colors.blueAccent.withOpacity(0.2) : Colors.transparent),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isDone ? Colors.blueAccent : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(time, style: TextStyle(color: isDone ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(menu, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, decoration: isDone ? TextDecoration.lineThrough : null)),
                Text(reason, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          if (isDone) const Icon(Icons.check_circle, color: Colors.blueAccent)
          else const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1);
  }

  Widget _buildUpcomingPlan() {
    final tomorrow = _dietPlan!['diet_plan'][1];
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
              SizedBox(width: 8),
              Text('내일의 예측 식단', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${tomorrow['meals']['dinner']['menu']} 어떠신가요? ${tomorrow['meals']['dinner']['reason']}',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {},
            child: const Text('식단 계획 전체 보기', style: TextStyle(color: Colors.amber)),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }
}
