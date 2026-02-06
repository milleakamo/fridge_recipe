import 'package:flutter/material.dart';
import 'package:fridge_recipe/models/ingredient.dart';

class SavedAmountInfoDialog extends StatelessWidget {
  const SavedAmountInfoDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('식비 절감액 계산 기준'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('• 유통기한 임박 식재료 (3일 이내):'),
          Padding(
            padding: EdgeInsets.only(left: 12.0, bottom: 8.0),
            child: Text('구매가액의 100% 절감 인정', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
          ),
          Text('• 일반 식재료:'),
          Padding(
            padding: EdgeInsets.only(left: 12.0),
            child: Text('구매가액의 20% 절감 인정', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          SizedBox(height: 16),
          Text('버려질 뻔한 식재료를 활용함으로써 실제 지출을 방어한 금액을 계산합니다.', style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('확인'),
        ),
      ],
    );
  }
}
