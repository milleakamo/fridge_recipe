import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fridge_recipe/screens/neighborhood_trade_detail_screen.dart';

class NeighborhoodTradeScreen extends StatelessWidget {
  const NeighborhoodTradeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('이웃간 재료 나눔', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.location_on, color: Colors.blueAccent), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBanner(),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('우리 동네 실시간 나눔', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            _buildTradeItem(context, '유통기한 임박 대파 반단', '방배동 가재님', '무료나눔', '300m', true),
            _buildTradeItem(context, '남은 양파 2개', '서초동 투자자님', '500원', '800m', false),
            _buildTradeItem(context, '새 상품 스팸 200g', '반포동 셰프님', '2,000원', '1.2km', false),
            const SizedBox(height: 24),
            _buildRevenueModelNote(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: Colors.blueAccent,
        label: const Text('재료 올리기'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('버리지 말고 이웃과 나누세요', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('탄소 배출 저감 및 가계 경제 활성화', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
        ],
      ),
    ).animate().fadeIn().slideX();
  }

  Widget _buildTradeItem(BuildContext context, String title, String user, String price, String distance, bool isFree) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NeighborhoodTradeDetailScreen(
              title: title,
              user: user,
              price: price,
              distance: distance,
              isFree: isFree,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.fastfood, color: Colors.grey),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('$user · $distance', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            Text(price, style: TextStyle(color: isFree ? Colors.orange : Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueModelNote() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blueAccent, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text('거래 시 발생하는 수수료의 1%는 환경 단체에 기부됩니다. (BM: 중개 수수료 및 로컬 광고)', 
              style: TextStyle(fontSize: 12, color: Colors.blueAccent)),
          ),
        ],
      ),
    );
  }
}
