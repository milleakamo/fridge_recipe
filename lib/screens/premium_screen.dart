import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({Key? key}) : super(key: key);

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  int _currentStep = 0;
  String? _selectedBudget;
  String? _selectedWaste;

  final Map<String, int> _budgetValues = {
    '3만원 미만': 20000,
    '3~5만원': 40000,
    '5~10만원': 75000,
    '10만원 이상': 150000,
  };

  final Map<String, double> _wasteRatios = {
    '거의 없음': 0.05,
    '조금 있음': 0.2,
    '절반 이상': 0.5,
  };

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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
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
          if (_currentStep == 0) ...[
            const Text('평소 장 보실 때\n얼마나 지출하시나요?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.4)),
            const SizedBox(height: 24),
            _buildOptions(['3만원 미만', '3~5만원', '5~10만원', '10만원 이상'], (val) {
              setState(() {
                _selectedBudget = val;
                _currentStep = 1;
              });
            }),
          ] else if (_currentStep == 1) ...[
            const Text('일주일 뒤,\n버려지는 재료는 어느 정도인가요?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.4)),
            const SizedBox(height: 24),
            _buildOptions(['거의 없음', '조금 있음', '절반 이상'], (val) {
              setState(() {
                _selectedWaste = val;
                _currentStep = 2;
              });
              _showSavingResultDialog(context);
            }),
            TextButton(
              onPressed: () => setState(() => _currentStep = 0),
              child: const Text('이전으로', style: TextStyle(color: Colors.grey)),
            ),
          ] else ...[
            const Text('분석이 완료되었습니다.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('냉장고 속 숨은 돈을 찾아보세요.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep = 0),
                child: const Text('다시 계산하기'),
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1);
  }

  Widget _buildOptions(List<String> options, Function(String) onSelect) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((option) => InkWell(
        onTap: () => onSelect(option),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.transparent),
          ),
          child: Text(option, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ),
      )).toList(),
    );
  }

  void _showSavingResultDialog(BuildContext context) {
    final budget = _budgetValues[_selectedBudget] ?? 0;
    final ratio = _wasteRatios[_selectedWaste] ?? 0;
    final monthlyWaste = (budget * ratio * 4.3).toInt();
    final yearlySaving = (monthlyWaste * 12);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.lightbulb, color: Colors.amber),
            SizedBox(width: 8),
            Text('절약 잠재력 분석', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('투자자님, 한 달에 약 ${NumberFormat('#,###').format(monthlyWaste)}원을\n쓰레기통에 버리고 계셨네요.', 
              style: const TextStyle(fontSize: 15, height: 1.5)),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text('가재 프리미엄 구독 시', style: TextStyle(fontSize: 12, color: Colors.blueAccent)),
                  const SizedBox(height: 4),
                  Text('연간 약 ${NumberFormat('#,###').format(yearlySaving)}원 절약 가능', 
                    style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('프리미엄 혜택 보기'),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('AI 스마트 최저가 연동', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('NEW', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('부족한 재료를 한 번의 터치로 가장 저렴한 마켓에서 주문하세요.', style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 20),
          _buildPriceItem('유기농 대란 15구', '쿠팡 (로켓배송)', '₩4,980', true),
          _buildPriceItem('서울우유 1L', '이마트 (쓱배송)', '₩2,850', false),
          _buildPriceItem('국산 흙대파', '마켓컬리 (샛별배송)', '₩2,100', true),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.shopping_cart, size: 18),
              label: const Text('최저가 장바구니 일괄 결제'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF3F4F6),
                foregroundColor: Colors.black87,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
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
