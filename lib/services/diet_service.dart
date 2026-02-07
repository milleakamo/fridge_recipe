import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fridge_recipe/models/ingredient.dart';

class DietService {
  Future<Map<String, dynamic>> generateDietPlan(List<Ingredient> ingredients) async {
    final response = await http.post(
      Uri.parse('/api/generate-diet'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'ingredients': ingredients.map((i) => i.toJson()).toList(),
        'mode': 'health_focus',
        'health_profile': 'high_protein'
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to generate diet plan');
    }
  }
}
