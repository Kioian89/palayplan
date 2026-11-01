import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'disease_prediction.dart';

class DiseaseClassifier {
  bool _isInitialized = false;
  List<String> _labels = [];

  bool get isInitialized => _isInitialized;
  List<String> get labels => List.unmodifiable(_labels);

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      final labelData = await rootBundle.loadString('assets/models/labels.txt');
      _labels = labelData
          .split('\n')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      _isInitialized = true;
      debugPrint('DiseaseClassifier (Web preview mode) initialized.');
    } catch (e) {
      debugPrint('Error loading labels on web: $e');
    }
  }

  Future<DiseasePrediction> predict(dynamic imageFile) async {
    if (!_isInitialized) {
      await initialize();
    }
    // Web preview fallback (native on-device TFLite runs when launched on Android/iOS/Desktop)
    await Future.delayed(const Duration(milliseconds: 600));
    return const DiseasePrediction(
      label: 'bacterial_leaf_blight',
      confidence: 0.88,
    );
  }

  void close() {
    _isInitialized = false;
  }
}

