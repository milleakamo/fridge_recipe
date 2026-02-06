import 'package:flutter/material.dart';
import 'package:fridge_recipe/models/ingredient.dart';
import 'package:intl/intl.dart';

class IngredientCard extends StatelessWidget {
  final Ingredient ingredient;
  final VoidCallback onConsume;

  const IngredientCard({
    Key? key,
    required this.ingredient,
    required this.onConsume,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');
    final daysLeft = ingredient.expiryDate.difference(DateTime.now()).inDays;
    
    return InkWell(
      onLongPress: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('재료 삭제'),
            content: Text('${ingredient.name}을(를) 삭제하시겠습니까?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
              TextButton(
                onPressed: () {
                  ingredient.delete();
                  Navigator.pop(context);
                },
                child: const Text('삭제', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: ingredient.isConsumed ? Colors.grey[100] : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                ingredient.isConsumed ? Icons.check : Icons.restaurant, 
                color: ingredient.isConsumed ? Colors.green : const Color(0xFF9CA3AF)
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ingredient.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 16, 
                      color: ingredient.isConsumed ? Colors.grey : const Color(0xFF1F2937),
                      decoration: ingredient.isConsumed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ingredient.isConsumed 
                        ? '소비 완료'
                        : (daysLeft < 0 ? '만료됨' : (daysLeft == 0 ? '오늘까지' : '$daysLeft일 남음')),
                    style: TextStyle(
                      fontSize: 13, 
                      color: ingredient.isConsumed 
                          ? Colors.grey 
                          : (daysLeft <= 3 ? const Color(0xFFEF4444) : const Color(0xFF6B7280)),
                      fontWeight: (!ingredient.isConsumed && daysLeft <= 3) ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            if (!ingredient.isConsumed)
              TextButton(
                onPressed: onConsume,
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFEFF6FF),
                  foregroundColor: const Color(0xFF3B82F6),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('사용', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }
}
