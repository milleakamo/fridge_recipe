import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Premium Kitchen', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(),
            _buildSavingSimulator(context),
            _buildNutritionAnalysis(),
            _buildPriceComparisonSection(),
            _buildFamilySyncSection(),
            _buildPricingSection(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingSimulator(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.orange.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.calculate, color: Colors.orange, size: 24),
              ),
              const SizedBox(width: 12),
              const Text('원터치 절약 시뮬레이터', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          const Text('냉장고 속 버려질 3,400원,\n지금 식단으로 살려보세요.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.4)),
          const SizedBox(height: 24),
          _buildSimulatorStep('Q1. 장 보실 때 보통 얼마 정도 쓰시나요?', ['3만원 미만', '3~5만원', '5~10만원', '10만원 이상']),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                _showSavingResultDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('내 돈 지키기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1);
  }

  Widget _buildSimulatorStep(String question, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(option, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          )).toList(),
        ),
      ],
    );
  }

  void _showSavingResultDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('💡 절약 잠재력 분석', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('투자자님, 한 달에 약 45,000원을 쓰레기통에 버리고 계셨네요.', style: TextStyle(fontSize: 15, height: 1.5)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text('프리미엄 구독 시 연간 120만원 절약 가능', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('프리미엄 혜택 보기', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.amber, Colors.orange]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 12)],
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 40),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 24),
          const Text('내 냉장고의 한계를 넘다', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
          const SizedBox(height: 8),
          const Text('수익형 프리미엄 기능을 지금 경험해보세요', style: TextStyle(fontSize: 15, color: Color(0xFF6B7280))),
        ],
      ),
    );
  }

  Widget _buildNutritionAnalysis() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.health_and_safety, color: Colors.blueAccent),
              SizedBox(width: 8),
              Text('AI 정밀 영양 분석', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(color: Colors.blueAccent, value: 40, title: '탄수화물', radius: 50, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  PieChartSectionData(color: Colors.orange, value: 35, title: '단백질', radius: 50, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  PieChartSectionData(color: Colors.green, value: 25, title: '지방', radius: 50, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('현재 냉장고 재료로는 단백질이 조금 부족해요! 내일 점심은 닭가슴살 샐러드 어떠신가요?', style: TextStyle(color: Color(0xFF4B5563), fontSize: 13, height: 1.5)),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }

  Widget _buildPriceComparisonSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('실시간 최저가 장바구니', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Icon(Icons.shopping_cart_outlined, color: Colors.orange),
            ],
          ),
          const SizedBox(height: 16),
          _buildPriceItem('유기농 대란 15구', '쿠팡', '₩4,980', true),
          _buildPriceItem('서울우유 1L', '이마트', '₩2,850', false),
          _buildPriceItem('국산 흙대파', '마켓컬리', '₩2,100', true),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildPriceItem(String name, String market, String price, bool isLowest) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(market, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          Row(
            children: [
              if (isLowest) Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: const Text('최저가', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              Text(price, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFamilySyncSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Row(
        children: [
          Icon(Icons.people_alt, color: Colors.white, size: 32),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('가족 공유 시스템', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('남편, 아내와 실시간 재고 공유', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1);
  }

  Widget _buildPricingSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          const Text('매월 치킨 한 마리 값으로 냉장고 혁명', style: TextStyle(color: Colors.amber, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('₩1,900', style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900)),
              Text('/월', style: TextStyle(color: Colors.white54, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('수익 창출을 위한 결제 모듈 연동 중입니다!')));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('프리미엄 무제한 이용하기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms).scale(begin: const Offset(0.95, 0.95));
  }
}
