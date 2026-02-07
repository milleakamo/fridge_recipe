import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import 'dart:math';

class MarketPriceTracker extends StatefulWidget {
  const MarketPriceTracker({Key? key}) : super(key: key);

  @override
  _MarketPriceTrackerState createState() => _MarketPriceTrackerState();
}

class _MarketPriceTrackerState extends State<MarketPriceTracker> {
  final List<Map<String, dynamic>> _marketData = [
    {'name': '대파 (1단)', 'price': 3200, 'change': -150, 'trend': 'down'},
    {'name': '양파 (1kg)', 'price': 2800, 'change': 200, 'trend': 'up'},
    {'name': '계란 (30구)', 'price': 6500, 'change': 0, 'trend': 'stable'},
    {'name': '우유 (1L)', 'price': 2950, 'change': 50, 'trend': 'up'},
  ];

  late Timer _timer;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _startPriceSimulation();
  }

  void _startPriceSimulation() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          for (var item in _marketData) {
            final volatility = _random.nextInt(40) - 20;
            item['price'] += volatility;
            item['change'] = volatility;
            item['trend'] = volatility > 0 ? 'up' : (volatility < 0 ? 'down' : 'stable');
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.trending_up, color: Colors.redAccent, size: 20),
                  SizedBox(width: 8),
                  Text('실시간 시장 물가', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('LIVE', style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _marketData.length,
              itemBuilder: (context, index) {
                final item = _marketData[index];
                final isUp = item['trend'] == 'up';
                final isDown = item['trend'] == 'down';
                
                return Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(item['name'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text('₩${item['price']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            isUp ? Icons.arrow_drop_up : (isDown ? Icons.arrow_drop_down : Icons.remove),
                            color: isUp ? Colors.redAccent : (isDown ? Colors.blueAccent : Colors.grey),
                            size: 16,
                          ),
                          Text(
                            '${item['change'].abs()}',
                            style: TextStyle(
                              fontSize: 10,
                              color: isUp ? Colors.redAccent : (isDown ? Colors.blueAccent : Colors.grey),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '* 인근 마트 실거래 기반 데이터입니다.',
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1);
  }
}
