import 'package:hive/hive.dart';

part 'ingredient.g.dart';

@HiveType(typeId: 0)
class Ingredient extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final DateTime addedDate;

  @HiveField(3)
  final DateTime expiryDate;

  @HiveField(4)
  final double originalPrice;

  @HiveField(5)
  bool isConsumed;

  Ingredient({
    required this.id,
    required this.name,
    required this.addedDate,
    required this.expiryDate,
    this.originalPrice = 0.0,
    this.isConsumed = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'addedDate': addedDate.toIso8601String(),
    'expiryDate': expiryDate.toIso8601String(),
    'originalPrice': originalPrice,
    'isConsumed': isConsumed,
  };

  bool get isNearExpiry {
    final diff = expiryDate.difference(DateTime.now()).inDays;
    return diff <= 3 && diff >= 0;
  }

  double get savedAmount {
    if (!isConsumed) return 0.0;
    // 유통기한 임박(3일 이내) 100%, 일반 20%
    return isNearExpiry ? originalPrice : originalPrice * 0.2;
  }
}
