import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
          
          if (result['items'] != null) {
            _scannedItems = (result['items'] as List).map((item) {
              return Ingredient(
                id: const Uuid().v4(),
                name: item['name'] ?? '알 수 없는 재료',
                addedDate: DateTime.now(),
                expiryDate: DateTime.now().add(Duration(days: (item['expiry_days'] ?? 7).toInt())),
                originalPrice: (item['price'] ?? 0.0).toDouble(),
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
      // 단순 로직: 화면 비율이나 사용자 선택에 따라 나눌 수 있으나, 일단 영수증 모드로 자동 전환 시도 (또는 UI에서 선택 가능하게 변경)
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
          // 카메라 프리뷰
          Center(
            child: CameraPreview(_controller!),
          ),

          // 스캐닝 오버레이
          if (_isScanning)
            _buildScanningOverlay(),

          // 인식된 바운딩 박스
          if (_isScanning || _showResults)
            ..._detectedBoxes.map((rect) => _buildBoundingBox(rect)),

          // 상단 가이드
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
                    'AI 재료 스캔',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),

          // 하단 버튼 또는 결과 리스트
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
            const CircularProgressIndicator(color: Colors.blueAccent),
            const SizedBox(height: 24),
            const Text('AI 영수증 분석 중...', 
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('토스처럼 빠르고 정확하게 데이터를 추출합니다.', 
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
          ],
        ),
      ),
    ).animate().fadeIn();
  }

  Widget _buildBoundingBox(Rect rect) {
    return Positioned(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blueAccent, width: 2),
          borderRadius: BorderRadius.circular(8),
          color: Colors.blueAccent.withOpacity(0.1),
        ),
      ).animate(onPlay: (controller) => controller.repeat())
       .shimmer(duration: 1500.ms, color: Colors.white.withOpacity(0.5)),
    );
  }

  Widget _buildScanButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 50.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '영수증이나 냉장고 안을 비춰주세요',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 갤러리 버튼
                IconButton(
                  onPressed: _isScanning ? null : _pickFromGallery,
                  icon: const Icon(Icons.photo_library, color: Colors.white, size: 40),
                ),
                const SizedBox(width: 40),
                // 촬영 버튼
                GestureDetector(
                  onTap: _isScanning ? null : _startScan,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 40),
                // 라이트 버튼 (추후 구현)
                const IconButton(
                  onPressed: null,
                  icon: Icon(Icons.flash_on, color: Colors.white, size: 40),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSheet() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 450,
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
                  '인식 결과',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_scannedItems.length}개 발견',
                  style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _scannedItems.length,
                itemBuilder: (context, index) {
                  final item = _scannedItems[index];
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.restaurant, color: Colors.blueGrey),
                    ),
                    title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('유통기한: ${item.expiryDate.toString().split(' ')[0]} (자동 계산됨)'),
                    trailing: const Icon(Icons.check_circle, color: Colors.green),
                  ).animate().slideX(begin: 1.0, delay: (index * 100).ms);
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _showResults = false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('다시 찍기'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, _scannedItems);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('냉장고에 넣기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ).animate().slideY(begin: 1.0),
    );
  }
}
