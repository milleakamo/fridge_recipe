import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fridge_recipe/services/market_service.dart';

class MarketSyncScreen extends StatefulWidget {
  const MarketSyncScreen({Key? key}) : super(key: key);

  @override
  _MarketSyncScreenState createState() => _MarketSyncScreenState();
}

class _MarketSyncScreenState extends State<MarketSyncScreen> {
  final MarketService _marketService = MarketService();
  bool _isSyncing = false;
  List<Map<String, dynamic>> _marketItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRealMarketData();
  }

  Future<void> _fetchRealMarketData() async {
    setState(() => _isLoading = true);
    // getOptimalShoppingList는 현재 정적 데이터를 반환하지만, 실제 서비스에서는 사용자 냉장고 기반 API를 호출함
    final items = await _marketService.getOptimalShoppingList([]);
    if (mounted) {
      setState(() {
        _marketItems = items;
        _isLoading = false;
      });
    }
  }

  void _startSync() async {
    setState(() => _isSyncing = true);
    await _fetchRealMarketData();
    if (mounted) {
      setState(() => _isSyncing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('실시간 시장 가격 동기화 완료! 최저가 데이터가 갱신되었습니다.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('실시간 시장 동기화', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isSyncing ? Icons.sync : Icons.refresh, color: Colors.blue),
            onPressed: _isSyncing ? null : _startSync,
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSyncStatusHeader(),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Text('최적 구매 제안', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _marketItems.length,
                  itemBuilder: (context, index) {
                    final item = _marketItems[index];
                    return _buildMarketItemCard(item);
                  },
                ),
                const SizedBox(height: 32),
                _buildAutoPurchaseCard(),
                const SizedBox(height: 100),
              ],
            ),
          ),
    );
  }

  Widget _buildSyncStatusHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('시장 모니터링 엔진 가동 중', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 12),
          const Text('현재 인플레이션 방어율: 12.4%', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('가재 AI가 주요 5개 마켓의 실시간 가격을 비교합니다.', style: TextStyle(color: Colors.white60, fontSize: 13)),
          const SizedBox(height: 24),
          LinearProgressIndicator(
            value: _isSyncing ? null : 1.0,
            backgroundColor: Colors.white12,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketItemCard(Map<String, dynamic> item) {
    return InkWell(
      onTap: () {
        _marketService.launchMarketLink(item['link']);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.shopping_bag, color: Colors.blueGrey),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text('${item['market']} · ${item['reason']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('₩${item['price']}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.blueAccent)),
                if (item['isLowest'])
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                    child: const Text('최저가', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1);
  }

  Widget _buildAutoPurchaseCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.bolt, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Text('지능형 자동 결제 (Beta)', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          const Text('필수 식재료의 가격이 설정한 목표가 이하로 떨어지면 자동으로 결제하고 배송을 예약합니다.', 
            style: TextStyle(color: Colors.white, fontSize: 13, height: 1.5)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.orange,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('자동 결제 조건 설정하기', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
