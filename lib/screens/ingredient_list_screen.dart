import 'package:flutter/material.dart';
import 'package:fridge_recipe/models/ingredient.dart';
import 'package:fridge_recipe/widgets/ingredient_card.dart';
import 'package:hive_flutter/hive_flutter.dart';

class IngredientListScreen extends StatefulWidget {
  const IngredientListScreen({Key? key}) : super(key: key);

  @override
  _IngredientListScreenState createState() => _IngredientListScreenState();
}

class _IngredientListScreenState extends State<IngredientListScreen> {
  late Box<Ingredient> _ingredientBox;
  bool _showConsumed = false;

  @override
  void initState() {
    super.initState();
    _ingredientBox = Hive.box<Ingredient>('ingredients');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('전체 재료 목록', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        actions: [
          Row(
            children: [
              const Text('소비 완료 포함', style: TextStyle(color: Colors.grey, fontSize: 12)),
              Switch(
                value: _showConsumed,
                onChanged: (value) => setState(() => _showConsumed = value),
                activeColor: Colors.blueAccent,
              ),
            ],
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: _ingredientBox.listenable(),
        builder: (context, Box<Ingredient> box, _) {
          final items = box.values.where((i) => _showConsumed || !i.isConsumed).toList();
          items.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));

          if (items.isEmpty) {
            return const Center(child: Text('표시할 재료가 없습니다.'));
          }

          return ListView.builder(
            itemCount: items.length,
            padding: const EdgeInsets.only(bottom: 24),
            itemBuilder: (context, index) {
              final item = items[index];
              return IngredientCard(
                ingredient: item,
                onConsume: () {
                  setState(() {
                    item.isConsumed = true;
                    item.save();
                  });
                },
              );
            },
          );
        },
      ),
    );
  }
}
