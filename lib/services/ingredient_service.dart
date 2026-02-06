import '../models/ingredient.dart';

class IngredientService {
  static const Map<String, int> defaultExpiryDays = {
    '소고기': 5,
    '돼지고기': 3,
    '삼겹살': 3,
    '닭고기': 2,
    '생선': 2,
    '조개': 1,
    '우유': 10,
    '치즈': 30,
    '계란': 30,
    '달걀': 30,
    '양파': 30,
    '감자': 30,
    '대파': 7,
    '당근': 14,
    '두부': 5,
    '애호박': 5,
    '양배추': 7,
    '버섯': 3,
    '콩나물': 3,
    '숙주': 3,
    '햄': 14,
    '소시지': 14,
    '마늘': 30,
    '김치': 180,
    '식빵': 5,
    '빵': 5,
    '참치': 365,
    '옥수수': 365,
    '어묵': 7,
    '상추': 3,
    '깻잎': 3,
    '오이': 5,
    '고추': 7,
  };

  static DateTime suggestExpiryDate(String name) {
    int days = 3; // 기본값 3일 (보수적)
    
    for (var entry in defaultExpiryDays.entries) {
      if (name.contains(entry.key)) {
        days = entry.value;
        break;
      }
    }
    
    return DateTime.now().add(Duration(days: days));
  }
}
