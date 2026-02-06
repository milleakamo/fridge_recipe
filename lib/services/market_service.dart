import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:fridge_recipe/models/ingredient.dart';

class MarketService {
  final String _baseUrl = 'https://fridge-recipe-alpha.vercel.app/api';

  Future<List<Map<String, dynamic>>> getOptimalShoppingList(List<Ingredient> ingredients) async {
    // 실제 구현에서는 부족한 재료 분석 및 마켓 API 연동
    // 현재는 POC용 시뮬레이션 데이터 반환
    await Future.delayed(const Duration(seconds: 1));
    
    return [
      {
        'name': '계란 15구',
        'market': '쿠팡',
        'price': 4980,
        'isLowest': true,
        'link': 'https://link.coupang.com/example',
        'reason': '단백질 보충 필요'
      },
      {
        'name': '우유 1L',
        'market': '이마트',
        'price': 2850,
        'isLowest': false,
        'link': 'https://emart.ssg.com/example',
        'reason': '재고 소진 임박'
      }
    ];
  }

  Future<Map<String, dynamic>> predictConsumption(List<Ingredient> ingredients) async {
    // 소비 패턴 기반 유통기한 전 소진 가능성 예측 AI
    await Future.delayed(const Duration(seconds: 1));
    return {
      'score': 85,
      'risky_items': ['우유', '두부'],
      'advice': '우유의 유통기한이 2일 남았습니다. 오늘 저녁 크림 파스타를 추천합니다.'
    };
  }
}
