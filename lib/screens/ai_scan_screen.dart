import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fridge_recipe/models/ingredient.dart';
import 'package:fridge_recipe/services/vision_service.dart';
import 'package:uuid/uuid.dart';

class AIScanScreen extends StatefulWidget {
  const AIScanScreen({Key? key}) : super(key: key);

  @override
  _AIScanScreenState createState() => _AIScanScreenState();
}

class _AIScanScreenState extends State<AIScanScreen> {
  CameraController? _controller;
  bool _isScanning = false;
  bool _showResults = false;
  List<Ingredient> _scannedItems = [];
  double _estimatedSavings = 0;
  int _nonFoodCount = 0;
  final ImagePicker _picker = ImagePicker();
  
  final List<Rect> _detectedBoxes = [
    const Rect.fromLTWH(50, 200, 100, 100),
    const Rect.fromLTWH(200, 300, 80, 80),
    const Rect.fromLTWH(100, 450, 120, 120),
  ];

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
    _controller = CameraController(cameras[0], ResolutionPreset.high);
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _processImage(String base64Image, {bool isReceipt = false}) async {
    setState(() {
      _isScanning = true;
      _showResults = false;
    });

    try {
      final result = isReceipt 
          ? await VisionService.analyzeReceipt(base64Image)
          : await VisionService.analyzeFridge(base64Image);

      if (mounted) {
        setState(() {
          _isScanning = false;
          _showResults = true;
          // Use 'estimated_savings' or 'total_estimated_savings' from API
          _estimatedSavings = (result['estimated_savings'] ?? result['total_estimated_savings'] ?? 0).toDouble();
          _nonFoodCount = (result['non_food_items_count'] ?? result['non_food_count_excluded'] ?? 0).toInt();
          
          if (result['items'] != null) {
            _scannedItems = (result['items'] as List).map((item) {
              return Ingredient(
                id: const Uuid().v4(),
                name: item['name'] ?? '알 수 없는 재료',
                addedDate: DateTime.now(),
                expiryDate: DateTime.now().add(Duration(days: (item['expiry_days'] ?? 7).toInt())),
                originalPrice: (item['price'] ?? 0.0).toDouble(),
                isFood: item['is_food'] == true || item['is_edible'] == true, 
              );
            }).toList();
          }
        });
        
        if (_scannedItems.isNotEmpty) {
          Confetti.launch(
            context,
            options: const ConfettiOptions(
              particleCount: 100,
              spread: 70,
              y: 0.6,
            ),
          );
        }
      }
    } catch (e) {
      print('Scan error: $e');
      if (mounted) {
        setState(() => _isScanning = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('스캔 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  void _startScan() async {
    try {
      final image = await _controller!.takePicture();
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);
      await _processImage(base64Image, isReceipt: true);
    } catch (e) {
      print('Camera capture error: $e');
    }
  }

  void _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64Image = base64Encode(bytes);
        await _processImage(base64Image, isReceipt: true);
      }
    } catch (e) {
      print('Gallery pick error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: CameraPreview(_controller!),
          ),
          if (_isScanning)
            _buildScanningOverlay(),
          if (_isScanning || _showResults)
            ..._detectedBoxes.map((rect) => _buildBoundingBox(rect)),
          _buildScanningLine(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'AI 영수증 스캔',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
          _showResults ? _buildResultsSheet() : _buildScanButton(),
        ],
      ),
    );
  }

  Widget _buildScanningOverlay() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 150,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF0047FF), width: 2),
              ),
              child: Stack(
                children: [
                  const Positioned.fill(
                    child: Icon(Icons.receipt_long, color: Colors.white54, size: 80),
                  ),
                  _buildScanningBar(),
                ],
              ),
            ).animate(onPlay: (controller) => controller.repeat())
             .shimmer(duration: 2.seconds, color: const Color(0xFF0047FF).withOpacity(0.3)),
            const SizedBox(height: 40),
            DefaultTextStyle(
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              child: AnimatedTextKit(
                animatedTexts: [
                  TyperAnimatedText('영수증에서 재료를 찾고 있어요...'),
                  TyperAnimatedText('이 재료들로 만들 수 있는 레시피가 5개나 있어요!'),
                  TyperAnimatedText('식비 2,400원 절약 요소를 발견했어요! 🦞'),
                  TyperAnimatedText('분석 완료! 곧 냉장고에 넣어드릴게요. 🦞'),
                ],
                totalRepeatCount: 1,
                pause: const Duration(milliseconds: 500),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn();
  }

  Widget _buildScanningBar() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 2),
      builder: (context, value, child) {
        return Positioned(
          top: value * 200,
          left: 0,
          right: 0,
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF0047FF),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0047FF).withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScanningLine() {
    if (!_isScanning) return const SizedBox.shrink();
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 4),
      builder: (context, value, child) {
        final screenHeight = MediaQuery.of(context).size.height;
        return Positioned(
          top: value * screenHeight,
          left: 0,
          right: 0,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              color: const Color(0xFF0047FF).withOpacity(0.8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0047FF).withOpacity(0.6),
                  blurRadius: 15,
                  spreadRadius: 5,
                )
              ],
            ),
          ),
        );
      },
      onEnd: () {
        if (_isScanning) setState(() {});
      },
    );
  }

  Widget _buildBoundingBox(Rect rect) {
    return Positioned(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF0047FF), width: 2),
          borderRadius: BorderRadius.circular(8),
          color: const Color(0xFF0047FF).withOpacity(0.1),
        ),
      ).animate(onPlay: (controller) => controller.repeat())
       .shimmer(duration: 1500.ms, color: Colors.white.withOpacity(0.5)),
    );
  }

  Widget _buildScanButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.only(bottom: 50.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '영수증이나 냉장고 안을 비춰주세요',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCircularButton(
                  onPressed: _isScanning ? null : _pickFromGallery,
                  icon: Icons.photo_library,
                ),
                const SizedBox(width: 32),
                GestureDetector(
                  onTap: _isScanning ? null : _startScan,
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 32),
                _buildCircularButton(
                  onPressed: null,
                  icon: Icons.flash_on,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularButton({required VoidCallback? onPressed, required IconData icon}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: 28),
        padding: const EdgeInsets.all(12),
      ),
    );
  }

  Widget _buildResultsSheet() {
    double totalValue = _scannedItems.fold(0, (sum, item) => sum + (item.originalPrice ?? 0));
    
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 550,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                  const Text(
                    'AI 영수증 분석 완료',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${_scannedItems.where((i) => i.isFood).length}개 식재료 발견',
                    style: const TextStyle(color: Color(0xFF0047FF), fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (_nonFoodCount > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Gajae Filter: $_nonFoodCount개의 비식품이 자동 제외되었습니다.',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
            const SizedBox(height: 16),
            _buildValueCard(totalValue),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _scannedItems.length,
                itemBuilder: (context, index) {
                  final item = _scannedItems[index];
                  final isFood = item.isFood;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isFood ? Colors.white : Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isFood ? Colors.grey[200]! : Colors.transparent),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isFood ? const Color(0xFF0047FF).withOpacity(0.05) : Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFood ? Icons.restaurant : Icons.category_outlined,
                          color: isFood ? const Color(0xFF0047FF) : Colors.grey,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        item.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isFood ? Colors.black : Colors.grey,
                          decoration: isFood ? null : TextDecoration.lineThrough,
                        ),
                      ),
                      subtitle: Text(
                        isFood 
                          ? '유통기한 약 ${item.expiryDate.difference(DateTime.now()).inDays}일 남음'
                          : '식재료가 아닌 품목 (제외됨)',
                        style: TextStyle(fontSize: 12, color: isFood ? Colors.blueGrey : Colors.grey),
                      ),
                      trailing: Checkbox(
                        value: isFood,
                        onChanged: (val) {
                          // Manually toggle if needed
                        },
                        activeColor: const Color(0xFF0047FF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                  ).animate().slideX(begin: 1.0, delay: (index * 50).ms, curve: Curves.easeOutQuart);
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => setState(() => _showResults = false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.grey[100],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('다시 찍기', style: TextStyle(color: Colors.black)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Filter out non-food items before popping
                      final foodOnly = _scannedItems.where((i) => i.isFood).toList();
                      Navigator.pop(context, foodOnly);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0047FF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('내 냉장고에 넣기', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ).animate().slideY(begin: 1.0, curve: Curves.easeOutQuart),
    );
  }

  Widget _buildValueCard(double totalValue) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(20),
        border: _estimatedSavings > 0 
            ? Border.all(color: const Color(0xFF0047FF).withOpacity(0.3), width: 1)
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _estimatedSavings > 0 ? Icons.savings : Icons.account_balance_wallet, 
              color: const Color(0xFF0047FF)
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _estimatedSavings > 0 ? '오늘의 절약 포인트' : '오늘 담은 가치',
                  style: const TextStyle(fontSize: 13, color: Colors.blueGrey, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _estimatedSavings > 0 
                      ? '이번 영수증에서 ₩${_estimatedSavings.toStringAsFixed(0)}를 아꼈어요! 🦞'
                      : '₩${totalValue.toStringAsFixed(0)}의 식재료를 담았습니다!',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1);
  }
}
