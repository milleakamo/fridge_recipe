import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fridge_recipe/models/ingredient.dart';
import 'package:fridge_recipe/services/diet_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class DietScreen extends StatefulWidget {
  const DietScreen({Key? key}) : super(key: key);

  @override
  _DietScreenState createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  final DietService _dietService = DietService();
  Map<String, dynamic>? _dietPlan;
  bool _isLoading = false;
  final currencyFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');

  Future<void> _generateDietPlan() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final ingredientBox = Hive.box<Ingredient>('ingredients');
      final ingredients = ingredientBox.values.toList();
      final dietPlan = await _dietService.generate7DayDietPlan(ingredients);
      setState(() {
        _dietPlan = dietPlan;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI 엔진 연결 실패. 환경 설정을 확인해 주세요.')),
      );
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
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: _isLoading 
              ? _buildLoadingState()
              : _dietPlan == null
                ? _buildInitialState()
                : _buildDietContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 60.0,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      title: const Text('AI 7일 맞춤 식단', 
        style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w900, fontSize: 20)),
      centerTitle: false,
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 400,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFF3B82F6), strokeWidth: 3),
          const SizedBox(height: 24),
          const Text('냉장고를 분석 중...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('AI가 7일 완벽 식단을 짜드립니다.', style: TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFFEFF6FF), shape: BoxShape.circle),
                  child: const Icon(Icons.auto_awesome, size: 48, color: Color(0xFF3B82F6)),
                ),
                const SizedBox(height: 24),
                const Text('7일치 식비 0원 완전 무료', 
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, height: 1.2)),
                const SizedBox(height: 12),
                const Text('보유 중인 재료를 100% 활용하여\n7일간 완벽한 식단을 짜드립니다.', 
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 15, height: 1.5)),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    onPressed: _generateDietPlan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF111827),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                    ),
                    child: const Text('AI 7일 식단 엔진 가동하기', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1),
        ],
      ),
    );
  }

  Widget _buildDietContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSavingsHero(),
        _buildWeeklyTotals(),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Text('7일간의 완벽 플랜', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
        ),
        _build7DayCalendar(),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildSavingsHero() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('투자자님, 이번 7일간', style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(currencyFormat.format(62100), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
              const SizedBox(width: 4),
              const Text('을 아낄 수 있어요!', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('냉장고 파먹기 성공률 (AI 예측)', style: TextStyle(color: Color(0xEEFFFFFF), fontSize: 12, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        child: LinearProgressIndicator(
                          value: 0.92,
                          backgroundColor: Colors.white24,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                const Text('92%', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildWeeklyTotals() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_month, color: Color(0xFF6B7280)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('이번 주 식단 총계', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF111827))),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text('식비 ₩62,100 절약', style: TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDEF7EC),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('브론즈 등급', style: TextStyle(color: Color(0xFF059669), fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _build7DayCalendar() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 7,
      itemBuilder: (context, index) {
        final dayData = _dietPlan!['diet_plan'][index];
        return _buildDayCalendarCard(index + 1, dayData);
      },
    );
  }

  Widget _buildDayCalendarCard(int day, dynamic data) {
    final dayName = ['월', '화', '수', '목', '금', '토', '일'][day - 1];
    final isToday = day == DateTime.now().day;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isToday ? Colors.white : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isToday ? const Color(0xFF3B82F6) : Colors.transparent,
          width: isToday ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          if (isToday)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('오늘', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isToday ? const Color(0xFF3B82F6).withOpacity(0.1) : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('D-$day', style: TextStyle(color: isToday ? Color(0xFF3B82F6) : Color(0xFF6B7280), fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(dayName, style: TextStyle(color: isToday ? Color(0xFF3B82F6) : Color(0xFF6B7280), fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Day $day - ${day == 1 ? "최적 효율 식단" : day == 7 ? "잔여 재료 마무리" : "균형 잡힌 식단"}', 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF111827))),
                    const SizedBox(height: 4),
                    const Text('아침: 08:00, 점심: 12:45, 저녁: 18:30', 
                      style: TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('₩18,700', style: TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: ((day - 1) * 100).ms);
  }
}