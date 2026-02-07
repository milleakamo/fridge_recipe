import 'dart:math';

class LifeExtensionService {
  static String getExtensionTip(String ingredientName) {
    final tips = {
      '양파': '통풍이 잘 되는 그늘에 보관하면 수명이 2주 연장됩니다.',
      '대파': '씻어서 물기를 뺀 후 냉동 보관하면 수명이 3개월 연장됩니다.',
      '두부': '소금물을 넣은 밀폐용기에 담아 냉장 보관하세요.',
      '우유': '냉장고 문쪽보다 안쪽 깊숙이 보관하는 것이 좋습니다.',
    };
    return tips[ingredientName] ?? '밀폐 용기에 담아 냉장 보관하면 선도 유지가 쉽습니다.';
  }
}
