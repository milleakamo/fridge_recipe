import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ingredient.dart';

class YouTubeService {
  final String apiKey;
  static const String baseUrl = 'https://www.googleapis.com/youtube/v3';

  YouTubeService(this.apiKey);

  static const List<String> reliableChannels = [
    '백종원 PAIK JONG WON',
    '1분요리 뚝딱이형',
    '만개의레시피',
    '우리의식탁 Wooritable',
    '승우아빠',
    '식자대장',
  ];

  static const Map<String, int> top20Weights = {
    '대파': 10, '양파': 10, '두부': 9, '애호박': 9, '당근': 8,
    '양배추': 8, '버섯': 7, '콩나물': 7, '숙주': 7, '계란': 10,
    '햄': 8, '소시지': 8, '감자': 9, '마늘': 7, '고기': 8,
    '김치': 10, '식빵': 7, '빵': 7, '우유': 6, '치즈': 6,
    '참치': 5, '옥수수': 5, '어묵': 7, '상추': 5, '깻잎': 5,
  };

  Future<List<Map<String, dynamic>>> searchRecipes(dynamic queryInput) async {
    String query;
    if (queryInput is List<Ingredient>) {
      // 가중치 기반 검색 로직 (v1.0.8)
      // 1. 유통기한 임박 가중치 (3일 이내: 20점)
      // 2. 현실 식재료 20종 가중치 (최대 10점)
      final scoredItems = queryInput.where((i) => !i.isConsumed).map((i) {
        int score = 0;
        
        // 유통기한 임박 가중치
        final daysLeft = i.expiryDate.difference(DateTime.now()).inDays;
        if (daysLeft <= 3) score += 20;
        else if (daysLeft <= 7) score += 10;

        // 20종 식재료 가중치
        for (var entry in top20Weights.entries) {
          if (i.name.contains(entry.key)) {
            score += entry.value;
            break;
          }
        }
        
        return {'item': i, 'score': score};
      }).toList();

      scoredItems.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
      
      final ingredientNames = scoredItems
          .take(3)
          .map((e) => (e['item'] as Ingredient).name)
          .join(' ');
      
      query = '$ingredientNames 황금 레시피';
    } else {
      query = '$queryInput 황금 레시피';
    }
    
    final url = Uri.parse('$baseUrl/search?'
        'part=snippet'
        '&q=${Uri.encodeComponent(query)}'
        '&type=video'
        '&order=viewCount'
        '&videoCategoryId=26'
        '&relevanceLanguage=ko'
        '&regionCode=KR'
        '&maxResults=15'
        '&key=$apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> items = data['items'];
      
      final results = items.map((item) => {
        'id': item['id']['videoId'],
        'title': item['snippet']['title'],
        'thumbnail': item['snippet']['thumbnails']['high']['url'],
        'channelTitle': item['snippet']['channelTitle'],
        'isReliable': reliableChannels.any((c) => 
          (item['snippet']['channelTitle'] as String).contains(c))
      }).toList();

      // 신뢰할 수 있는 채널 우선 정렬
      results.sort((a, b) {
        if (a['isReliable'] == b['isReliable']) return 0;
        return a['isReliable'] ? -1 : 1;
      });

      return results;
    } else {
      throw Exception('Failed to load videos: ${response.body}');
    }
  }
}
