import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'disease_prediction.dart';

class DiseaseClassifier {
  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  List<String> get labels => List.unmodifiable(_labels);

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      // 1. Prefer the comprehensive 10-class model (with healthy leaf detection)
      String modelAsset = 'assets/models/rice_model_10class.tflite';
      String labelAsset = 'assets/models/labels_10class.txt';

      String labelData;
      try {
        labelData = await rootBundle.loadString(labelAsset);
        _interpreter = await Interpreter.fromAsset(modelAsset);
      } catch (e) {
        debugPrint('Falling back to 3-class rice model: $e');
        modelAsset = 'assets/models/rice_model.tflite';
        labelAsset = 'assets/models/labels.txt';
        labelData = await rootBundle.loadString(labelAsset);
        _interpreter = await Interpreter.fromAsset(modelAsset);
      }

      _labels = labelData
          .split('\n')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      _isInitialized = true;
      debugPrint(
          'DiseaseClassifier initialized with ${_labels.length} classes from $modelAsset: $_labels');
    } catch (e) {
      _interpreter?.close();
      _interpreter = null;
      _labels = [];
      throw StateError('Could not load the on-device disease model: $e');
    }
  }

  Future<DiseasePrediction> predict(dynamic imageFile) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_interpreter == null) {
      throw StateError(
        'Disease scanning is unavailable because the on-device model did not load.',
      );
    }

    Uint8List bytes;
    if (imageFile is File) {
      bytes = await imageFile.readAsBytes();
    } else {
      bytes = await (imageFile as dynamic).readAsBytes();
    }

    final image = img.decodeImage(bytes);
    if (image == null) {
      throw Exception('Could not decode image file.');
    }

    // High accuracy preprocessing:
    // Center-crop to 1:1 square first to maintain natural lesion shapes and leaf textures
    final square = img.copyResizeCropSquare(image, size: 224);

    // Model expects [1, 224, 224, 3] normalized [0.0, 1.0]
    final input = List.generate(
      1,
      (_) => List.generate(
        224,
        (y) => List.generate(
          224,
          (x) {
            final pixel = square.getPixel(x, y);
            return [
              pixel.r / 255.0,
              pixel.g / 255.0,
              pixel.b / 255.0,
            ];
          },
        ),
      ),
    );

    final output = List.generate(1, (_) => List.filled(_labels.length, 0.0));
    _interpreter!.run(input, output);

    // Apply softmax normalization if outputs are raw logits
    var probabilities = List<double>.from(output[0].map((e) => (e as num).toDouble()));
    final sum = probabilities.fold<double>(0.0, (acc, val) => acc + val);
    if ((sum - 1.0).abs() > 0.05) {
      final maxLogit = probabilities.reduce(math.max);
      final exps = probabilities.map((v) => math.exp(v - maxLogit)).toList();
      final expSum = exps.fold<double>(0.0, (acc, val) => acc + val);
      if (expSum > 0) {
        probabilities = exps.map((v) => v / expSum).toList();
      }
    }

    // Rank candidates by probability
    final indexed = List.generate(
      probabilities.length,
      (i) => MapEntry(i < _labels.length ? _labels[i] : 'unknown', probabilities[i]),
    )..sort((a, b) => b.value.compareTo(a.value));

    final topLabel = indexed.isNotEmpty ? indexed.first.key : 'unknown';
    final topProb = indexed.isNotEmpty ? indexed.first.value : 0.0;

    final candidates = indexed
        .take(3)
        .map((e) => DiseaseCandidate(label: e.key, confidence: e.value))
        .toList();

    return DiseasePrediction(
      label: topLabel,
      confidence: topProb,
      candidates: candidates,
    );
  }

  void close() {
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
  }
}
