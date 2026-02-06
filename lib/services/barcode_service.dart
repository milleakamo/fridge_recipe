import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fridge_recipe/models/ingredient.dart';
import 'package:uuid/uuid.dart';

class BarcodeService {
  Future<Ingredient?> lookupBarcode(String barcode) async {
    final response = await http.get(
      Uri.parse('/api/barcode-lookup?code=$barcode'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Ingredient(
        id: Uuid().v4(),
        name: data['name'],
        addedDate: DateTime.now(),
        expiryDate: DateTime.now().add(Duration(days: data['suggested_expiry_days'] ?? 7)),
        originalPrice: 0.0,
      );
    } else {
      return null;
    }
  }
}
