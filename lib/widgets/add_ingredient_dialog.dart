import 'package:flutter/material.dart';
import 'package:fridge_recipe/models/ingredient.dart';
import 'package:fridge_recipe/services/ingredient_service.dart';
import 'package:uuid/uuid.dart';

class AddIngredientDialog extends StatefulWidget {
  const AddIngredientDialog({Key? key}) : super(key: key);

  @override
  _AddIngredientDialogState createState() => _AddIngredientDialogState();
}

class _AddIngredientDialogState extends State<AddIngredientDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 7));

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('재료 추가', style: TextStyle(fontWeight: FontWeight.bold)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '재료 이름',
                  hintText: '예: 닭가슴살, 양파',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  // 이름 입력 시 유통기한 자동 제안
                  setState(() {
                    _expiryDate = IngredientService.suggestExpiryDate(value);
                  });
                },
                validator: (value) => (value == null || value.isEmpty) ? '이름을 입력하세요' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: '구매 가격 (₩)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => (value == null || value.isEmpty) ? '가격을 입력하세요' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('유통기한'),
                subtitle: Text('${_expiryDate.toLocal()}'.split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _expiryDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() => _expiryDate = picked);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final newIngredient = Ingredient(
                id: const Uuid().v4(),
                name: _nameController.text,
                addedDate: DateTime.now(),
                expiryDate: _expiryDate,
                originalPrice: double.tryParse(_priceController.text) ?? 0.0,
              );
              Navigator.pop(context, newIngredient);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
          ),
          child: const Text('추가'),
        ),
      ],
    );
  }
}
