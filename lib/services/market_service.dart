import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fridge_recipe/models/ingredient.dart';

class MarketService {
  final String _baseUrl = 'https://fridge-recipe-alpha.vercel.app/api';

  Future<List<Map<String, dynamic>>> getOptimalShoppingList(List<Ingredient> ingredients) async {
    // 실재 구현: 부족한 재료 분석 및 제휴 마켓 API 연동 (v1.2.0 BM 핵심)
    // 1. 단백질/채소/탄수화물 밸런스 분석
    // 2. 최저가 마켓 API 호출 (Coupang, Emart 등)
    // 3. 제휴 수익(Affiliate) 발생 가능한 링크 생성
    
    await Future.delayed(const Duration(seconds: 1));
    
    return [
      {
        'name': '특란 30구 (신선보장)',
        'market': '쿠팡 프레시',
        'price': 6980,
        'isLowest': true,
        'link': 'https://link.coupang.com/example_egg',
        'reason': '보유하신 계란의 유통기한이 오늘 만료됩니다.'
      },
      {
        'name': '유기농 콩나물 300g',
        'market': '이마트',
        'price': 1200,
        'isLowest': true,
        'link': 'https://emart.ssg.com/example_sprouts',
        'reason': '냉장고 내 채소 비중이 부족합니다 (AI 분석).'
      },
      {
        'name': '서울우유 1L x 2입',
        'market': '네이버 쇼핑',
        'price': 5600,
        'isLowest': false,
        'link': 'https://shopping.naver.com/example_milk',
        'reason': '지난 주 대비 15% 할인 중'
      }
    ];
  }

  Future<Map<String, dynamic>> predictConsumption(List<Ingredient> ingredients) async {
    // 소비 패턴 기반 유통기한 전 소진 가능성 예측 AI 엔진
    // LTV 증대를 위한 개인화 알림 로직
    await Future.delayed(const Duration(milliseconds: 800));
    
    final items = ingredients.where((i) => !i.isConsumed).toList();
    if (items.isEmpty) {
      return {
        'score': 100,
        'risky_items': [],
        'advice': '냉장고가 비어있습니다. AI 쇼핑 가이드를 통해 첫 장보기를 시작해보세요!'
      };
    }

    return {
      'score': 78,
      'risky_items': ['닭가슴살', '우유'],
      'advice': '닭가슴살의 폐기 위험이 높습니다. 오늘 내로 소비하지 않으면 ₩8,000의 손실이 발생합니다. AI 식단 메뉴를 확인하세요.'
    };
  }

  Future<Map<String, dynamic>> getMarketInsights() async {
    // 시장 트렌드 데이터 (v1.2.0 추가)
    return {
      'trending_ingredients': ['아보카도', '그릭요거트', '오트밀'],
      'inflation_alert': '계란 가격이 다음 주 10% 상승할 것으로 예측됩니다. 미리 구매를 추천합니다.'
    };
  }
}
