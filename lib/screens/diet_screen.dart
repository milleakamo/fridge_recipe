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
  bool _isPremium = true; // For v1.1.3 testing/showcase
  final currencyFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');

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
      floatingActionButton: _dietPlan != null ? FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('식단이 확정되었습니다. 재료에 사용 예정 태그가 부착되었습니다.'))
          );
        },
        backgroundColor: const Color(0xFF111827),
        label: const Text('AI가 제안한 식단 확정하기', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        icon: const Icon(Icons.check, color: Colors.white),
      ).animate().fadeIn().scale() : null,
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 60.0,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      title: const Text('AI 3일 맞춤 식단', 
        style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w900, fontSize: 20)),
      centerTitle: false,
      actions: [
        if (_dietPlan != null) IconButton(
          icon: const Icon(Icons.refresh, color: Color(0xFF4B5563)),
          onPressed: _generateDietPlan,
        ),
      ],
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
          const Text('투자자님의 냉장고를 분석 중...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('최적의 ROI 식단을 구성하고 있습니다.', style: TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
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
                const Text('3일치 식비 0원 도전', 
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, height: 1.2)),
                const SizedBox(height: 12),
                const Text('보유 중인 재료를 100% 활용하여\n추가 지출 없는 완벽한 식단을 짜드립니다.', 
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
                    child: const Text('AI 식단 엔진 가동하기', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
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
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Text('3일간의 절약 플랜', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
        ),
        _build3DayTabs(),
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
          const Text('투자자님, 이번 3일간', style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(currencyFormat.format(21800), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
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

  Widget _build3DayTabs() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        final dayData = _dietPlan!['diet_plan'][index];
        return _buildDayCard(index + 1, dayData);
      },
    );
  }

  Widget _buildDayCard(int day, dynamic data) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: day == 1 ? const Color(0xFF3B82F6).withOpacity(0.3) : const Color(0xFFF3F4F6), width: day == 1 ? 2 : 1),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: day == 1,
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: day == 1 ? const Color(0xFF3B82F6) : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text('D-$day', style: TextStyle(color: day == 1 ? Colors.white : const Color(0xFF6B7280), fontWeight: FontWeight.bold)),
            ),
          ),
          title: Text('Day $day - ${day == 1 ? "최적 효율 식단" : "잔여 재료 활용"}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Color(0xFF111827))),
          subtitle: Text(day == 1 ? '버려질 뻔한 식재료 3종 포함' : '추가 구매 필요 재료 0개', style: TextStyle(color: day == 1 ? Colors.orange : const Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.bold)),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Column(
                children: [
                  const Divider(height: 1),
                  _buildMealRow('아침', data['meals']['breakfast']['menu'], '4,500원 절약'),
                  _buildMealRow('점심', data['meals']['lunch']['menu'], '8,800원 절약'),
                  _buildMealRow('저녁', data['meals']['dinner']['menu'], '8,500원 절약'),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (day * 100).ms).slideX(begin: 0.05);
  }

  Widget _buildMealRow(String label, String menu, String saving) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
            child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4B5563))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(menu, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(saving, style: const TextStyle(color: Color(0xFF3B82F6), fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 18, color: Color(0xFFD1D5DB)),
        ],
      ),
    );
  }
}
