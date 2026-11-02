import 'disease_prediction.dart';

class DiseaseClassifier {
  bool _isInitialized = false;
  final List<String> _labels = [];

  bool get isInitialized => _isInitialized;
  List<String> get labels => List.unmodifiable(_labels);

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
  }

  Future<DiseasePrediction> predict(dynamic imageFile) async {
    if (!_isInitialized) {
      await initialize();
    }
    throw UnsupportedError(
      'On-device disease scanning is not available in the web app. '
      'Use the Android or iOS app to scan leaves offline.',
    );
  }

  void close() {
    _isInitialized = false;
  }
}
