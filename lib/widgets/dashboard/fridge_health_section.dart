import 'package:flutter/material.dart';
import 'package:fridge_recipe/models/ingredient.dart';
import 'package:intl/intl.dart';

class FridgeHealthSection extends StatelessWidget {
  final double score;
  final List<Ingredient> nearExpiryItems;
  final double totalValueAtRisk;

  const FridgeHealthSection({
    Key? key,
    required this.score,
    required this.nearExpiryItems,
    this.totalValueAtRisk = 0.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');
    Color scoreColor = const Color(0xFF34D399);
    if (score < 70) scoreColor = const Color(0xFFFBBF24);
    if (score < 40) scoreColor = const Color(0xFFF87171);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '냉장고 건강 지수',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5)),
            ],
          ),
          child: Row(
            children: [
              _buildGauge(score, scoreColor),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getHealthStatus(score),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF111827)),
                    ),
                    if (totalValueAtRisk > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        '약 ${currencyFormat.format(totalValueAtRisk)} 소멸 위기',
                        style: const TextStyle(color: Color(0xFFEF4444), fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      _getHealthMessage(score),
                      style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (nearExpiryItems.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '주의가 필요한 식재료',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF374151)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: nearExpiryItems.length,
              itemBuilder: (context, index) {
                return _buildWarningCard(nearExpiryItems[index]);
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGauge(double score, Color color) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: CircularProgressIndicator(
            value: score / 100,
            strokeWidth: 10,
            backgroundColor: const Color(0xFFF3F4F6),
            color: color,
            strokeCap: StrokeCap.round,
          ),
        ),
        Text(
          '${score.toInt()}',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
        ),
      ],
    );
  }

  Widget _buildWarningCard(Ingredient item) {
    final daysLeft = item.expiryDate.difference(DateTime.now()).inDays;
    
    return Container(
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFEDD5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            item.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF9A3412)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            daysLeft == 0 ? '오늘까지!' : '$daysLeft일 남음',
            style: const TextStyle(fontSize: 12, color: Color(0xFFC2410C), fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  String _getHealthStatus(double score) {
    if (score >= 80) return '아주 건강해요';
    if (score >= 50) return '관리가 필요해요';
    return '위험해요!';
  }

  String _getHealthMessage(double score) {
    if (score >= 80) return '식재료가 신선하게 유지되고 있어요.';
    if (score >= 50) return '유통기한이 임박한 재료가 있습니다.';
    return '버려질 위기의 재료들을 빨리 요리하세요!';
  }
}
