import 'dart:convert';
import 'package:http/http.dart' as http;

class VisionService {
  static const String fridgeUrl = '/api/analyze-fridge';
  static const String receiptUrl = '/api/analyze-receipt';

  static Future<Map<String, dynamic>> analyzeFridge(String base64Image) async {
    try {
      final response = await http.post(
        Uri.parse(fridgeUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'image': base64Image,
          'type': 'fridge',
          'options': {
            'identify_freshness': true,
            'estimate_quantity': true,
            'waste_prediction': true,
            'visual_quality_score': true
          }
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to analyze fridge: ${response.statusCode}');
      }
    } catch (e) {
      print('Error analyzing fridge: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> analyzeReceipt(String base64Image) async {
    try {
      final response = await http.post(
        Uri.parse(receiptUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'image': base64Image,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to analyze receipt: ${response.statusCode}');
      }
    } catch (e) {
      print('Error analyzing receipt: $e');
      rethrow;
    }
  }
}
