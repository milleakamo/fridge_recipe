import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fridge_recipe/models/ingredient.dart';
import 'package:fridge_recipe/screens/ai_scan_screen.dart';
import 'package:fridge_recipe/screens/recipe_list_screen.dart';
import 'package:fridge_recipe/screens/ingredient_list_screen.dart';
import 'package:fridge_recipe/screens/manual_add_screen.dart';
import 'package:fridge_recipe/screens/premium_screen.dart';
import 'package:fridge_recipe/widgets/add_ingredient_dialog.dart';
import 'package:fridge_recipe/widgets/dashboard/consumption_summary_card.dart';
import 'package:fridge_recipe/widgets/dashboard/consumption_timeline.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:fridge_recipe/services/barcode_service.dart';
import 'package:fridge_recipe/widgets/dashboard/fridge_health_section.dart';
import 'package:fridge_recipe/widgets/info_dialog.dart';
import 'package:fridge_recipe/widgets/ingredient_card.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeScreen extends StatefulWidget {
  final String apiKey;

  const HomeScreen({Key? key, required this.apiKey}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late Box<Ingredient> _ingredientBox;
  final BarcodeService _barcodeService = BarcodeService();
  final currencyFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');
  
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _ingredientBox = Hive.box<Ingredient>('ingredients');
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  double get _totalSavedAmount {
    return _ingredientBox.values
        .where((i) => i.isConsumed)
        .fold(0.0, (prev, element) => prev + element.savedAmount);
  }

  double get _fridgeHealthScore {
    if (_ingredientBox.isEmpty) return 100.0;
    final items = _ingredientBox.values.where((i) => !i.isConsumed).toList();
    if (items.isEmpty) return 100.0;
    
    final nearExpiryCount = items.where((i) => i.isNearExpiry).length;
    final score = 100.0 - (nearExpiryCount / items.length * 100.0);
    return score;
  }

  void _addSampleData() {
    final now = DateTime.now();
    final samples = [
      Ingredient(
        id: 'sample-1',
        name: '닭가슴살',
        addedDate: now,
        expiryDate: now.add(const Duration(days: 2)),
        originalPrice: 8000,
      ),
      Ingredient(
        id: 'sample-2',
        name: '우유',
        addedDate: now,
        expiryDate: now.add(const Duration(days: 5)),
        originalPrice: 3500,
      ),
      Ingredient(
        id: 'sample-3',
        name: '양파',
        addedDate: now,
        expiryDate: now.add(const Duration(days: 14)),
        originalPrice: 2000,
      ),
    ];
    for (var s in samples) {
      _ingredientBox.put(s.id, s);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('내 냉장고', 
              style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w900, fontSize: 24)),
            const SizedBox(width: 8),
            Text('v1.1.2', 
              style: TextStyle(color: Colors.grey.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_add, color: Color(0xFF4B5563)),
            onPressed: _addSampleData,
            tooltip: '샘플 데이터 추가',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_outlined, color: Color(0xFF4B5563)),
            onPressed: () => setState(() {}),
          ),
          IconButton(
            icon: const Icon(Icons.workspace_premium, color: Color(0xFFFBBF24)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PremiumScreen()),
              );
            },
            tooltip: '프리미엄 혜택',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: _ingredientBox.listenable(),
        builder: (context, Box<Ingredient> box, _) {
          final items = box.values.where((i) => !i.isConsumed).toList();
          final consumedItems = box.values.where((i) => i.isConsumed).toList();
          final nearExpiryItems = items.where((i) => i.isNearExpiry).toList();
          
          // 유통기한 순 정렬
          items.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));

          // 통계 데이터 계산
          final totalCount = box.length;
          final consumedRatio = totalCount > 0 ? consumedItems.length / totalCount : 0.0;
          final expiringRatio = totalCount > 0 ? nearExpiryItems.length / totalCount : 0.0;
          final wastedItems = items.where((i) => i.expiryDate.isBefore(DateTime.now())).toList();
          final wastedRatio = totalCount > 0 ? wastedItems.length / totalCount : 0.0;

          // 성장률 계산 (이번 주 vs 지난 주 - addedDate 기준)
          final now = DateTime.now();
          final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));
          final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
          
          final thisWeekSaved = consumedItems
              .where((i) => i.addedDate.isAfter(thisWeekStart))
              .fold(0.0, (sum, i) => sum + i.savedAmount);
          final lastWeekSaved = consumedItems
              .where((i) => i.addedDate.isAfter(lastWeekStart) && i.addedDate.isBefore(thisWeekStart))
              .fold(0.0, (sum, i) => sum + i.savedAmount);
          
          double growthRate = 0.0;
          if (lastWeekSaved > 0) {
            growthRate = ((thisWeekSaved - lastWeekSaved) / lastWeekSaved) * 100;
          } else if (thisWeekSaved > 0) {
            growthRate = 100.0;
          }

          // 타임라인 데이터 (최근 7일간 등록된 식재료 수)
          List<FlSpot> timelineSpots = [];
          for (int i = 6; i >= 0; i--) {
            final day = now.subtract(Duration(days: i));
            final count = box.values.where((item) => 
              item.addedDate.year == day.year && 
              item.addedDate.month == day.month && 
              item.addedDate.day == day.day
            ).length;
            timelineSpots.add(FlSpot((6 - i).toDouble(), count.toDouble()));
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ConsumptionSummaryCard(
                    totalSaved: _totalSavedAmount,
                    consumedRatio: consumedRatio,
                    expiringRatio: expiringRatio,
                    wastedRatio: wastedRatio,
                    growthRate: growthRate,
                  ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1),
                ),
                
                const SizedBox(height: 8),
                
                FridgeHealthSection(
                  score: _fridgeHealthScore,
                  nearExpiryItems: nearExpiryItems,
                ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.1),

                const SizedBox(height: 32),
                
                ConsumptionTimeline(
                  spots: timelineSpots,
                ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(begin: 0.1),

                const SizedBox(height: 32),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('내 냉장고 재료', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const IngredientListScreen()),
                          );
                        },
                        child: const Text('전체보기', style: TextStyle(color: Color(0xFF3B82F6))),
                      ),
                    ],
                  ),
                ),
                
                if (items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: Text('냉장고가 비어있습니다.', style: TextStyle(color: Colors.grey))),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length > 5 ? 5 : items.length,
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
                  ),
                
                const SizedBox(height: 120),
              ],
            ),
          );
        },
      ),
      floatingActionButton: _buildFloatingMenu(),
    );
  }

  Widget _buildFloatingMenu() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isMenuOpen) ...[
          _buildMenuStep(
            icon: Icons.qr_code_scanner,
            label: '바코드 스캔',
            color: Colors.blueGrey,
            onTap: () async {
              _toggleMenu();
              // 실제 바코드 스캔 로직
            },
            index: 3,
          ),
          _buildMenuStep(
            icon: Icons.add_a_photo,
            label: '영수증/사진 스캔',
            color: Colors.orangeAccent,
            onTap: () async {
              _toggleMenu();
              // AI 스캔 로직
            },
            index: 2,
          ),
          _buildMenuStep(
            icon: Icons.edit_note,
            label: '직접 입력',
            color: const Color(0xFF3B82F6),
            onTap: () async {
              _toggleMenu();
              // 직접 추가 로직
            },
            index: 1,
          ),
          _buildMenuStep(
            icon: Icons.auto_awesome,
            label: 'AI 식단 추천',
            color: const Color(0xFF1F2937),
            onTap: () {
              _toggleMenu();
              // 식단 페이지 이동
            },
            index: 0,
          ),
          const SizedBox(height: 16),
        ],
        FloatingActionButton(
          onPressed: _toggleMenu,
          backgroundColor: const Color(0xFF3B82F6),
          child: AnimatedRotation(
            turns: _isMenuOpen ? 0.125 : 0,
            duration: const Duration(milliseconds: 250),
            child: const Icon(Icons.add, color: Colors.white, size: 32),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuStep({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required int index,
  }) {
    return FadeTransition(
      opacity: _expandAnimation,
      child: ScaleTransition(
        scale: _expandAnimation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
                  ],
                ),
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1F2937)),
                ),
              ),
              const SizedBox(width: 12),
              FloatingActionButton.small(
                onPressed: onTap,
                backgroundColor: color,
                elevation: 4,
                child: Icon(icon, color: Colors.white, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('무엇을 할까요?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.qr_code,
                    label: '바코드 스캔',
                    color: Colors.blueGrey,
                    onTap: () async {
                      Navigator.pop(context);
                      String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
                          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
                      if (barcodeScanRes != '-1') {
                        final Ingredient? newIngredient = await _barcodeService.lookupBarcode(barcodeScanRes);
                        if (newIngredient != null) {
                          _ingredientBox.add(newIngredient);
                          setState(() {});
                        }
                      }
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.add_a_photo,
                    label: '사진 스캔',
                    color: Colors.orangeAccent,
                    onTap: () async {
                      Navigator.pop(context);
                      final List<Ingredient>? newItems = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AIScanScreen()),
                      );
                      if (newItems != null && newItems.isNotEmpty) {
                        for (var item in newItems) {
                          _ingredientBox.add(item);
                        }
                        setState(() {});
                      }
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.edit_note,
                    label: '직접 추가',
                    color: const Color(0xFF3B82F6),
                    onTap: () async {
                      Navigator.pop(context);
                      final bool? added = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ManualAddScreen()),
                      );
                      if (added == true) setState(() {});
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.restaurant_menu,
                    label: '레시피 추천',
                    color: const Color(0xFF1F2937),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeListScreen(
                            ingredients: _ingredientBox.values.toList(),
                            apiKey: widget.apiKey,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(BuildContext context, {required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
