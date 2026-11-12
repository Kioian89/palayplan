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
  String? _modelAsset;
  bool _isInitialized = false;
  Future<void>? _initialization;

  bool get isInitialized => _isInitialized;
  List<String> get labels => List.unmodifiable(_labels);

  Future<void> initialize() {
    if (_isInitialized) return Future<void>.value();
    if (_initialization != null) return _initialization!;

    final initialization = _initialize();
    _initialization = initialization;
    return initialization.whenComplete(() {
      if (identical(_initialization, initialization)) {
        _initialization = null;
      }
    });
  }

  Future<void> _initialize() async {
    if (_isInitialized) return;
    try {
      // 1. Prefer the comprehensive 10-class model (with healthy leaf detection)
      String modelAsset = 'assets/models/rice_model_10class.tflite';
      String labelAsset = 'assets/models/labels_10class.txt';

      String labelData;
      try {
        labelData = await rootBundle.loadString(labelAsset);
        _interpreter = await Interpreter.fromAsset(modelAsset);
        _labels = _parseLabels(labelData);
        _validateModel(_interpreter!, _labels, modelAsset);
      } catch (e) {
        debugPrint('10-class rice model is incompatible; falling back: $e');
        _interpreter?.close();
        _interpreter = null;
        _labels = [];
        modelAsset = 'assets/models/rice_model.tflite';
        labelAsset = 'assets/models/labels.txt';
        labelData = await rootBundle.loadString(labelAsset);
        _interpreter = await Interpreter.fromAsset(modelAsset);
        _labels = _parseLabels(labelData);
        _validateModel(_interpreter!, _labels, modelAsset);
      }

      _modelAsset = modelAsset;
      _isInitialized = true;
      debugPrint(
          'DiseaseClassifier initialized with ${_labels.length} classes from $modelAsset: $_labels');
    } catch (e) {
      _interpreter?.close();
      _interpreter = null;
      _labels = [];
      _modelAsset = null;
      throw StateError(
        'Could not load a compatible on-device disease model: $e',
      );
    }
  }

  List<String> _parseLabels(String labelData) {
    return labelData
          .split('\n')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
  }

  void _validateModel(
    Interpreter interpreter,
    List<String> labels,
    String modelAsset,
  ) {
    final inputs = interpreter.getInputTensors();
    final outputs = interpreter.getOutputTensors();
    if (inputs.length != 1 || outputs.length != 1) {
      throw StateError(
        '$modelAsset must have one input and one output tensor; '
        'found ${inputs.length} inputs and ${outputs.length} outputs.',
      );
    }

    final input = inputs.single;
    final output = outputs.single;
    const expectedInputShape = [1, 224, 224, 3];
    if (input.type != TensorType.float32 ||
        !listEquals(input.shape, expectedInputShape)) {
      throw StateError(
        '$modelAsset input must be float32 $expectedInputShape; '
        'found ${input.type} ${input.shape}.',
      );
    }

    final outputShape = output.shape;
    if (output.type != TensorType.float32 ||
        outputShape.length != 2 ||
        outputShape.first != 1 ||
        outputShape.last != labels.length) {
      throw StateError(
        '$modelAsset output must be float32 [1, ${labels.length}] to match '
        'its labels; found ${output.type} $outputShape.',
      );
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

    // The model includes MobileNetV2 preprocess_input, so pass RGB values in
    // the original [0, 255] range instead of normalizing them here.
    final input = List.generate(
      1,
      (_) => List.generate(
        224,
        (y) => List.generate(
          224,
          (x) {
            final pixel = square.getPixel(x, y);
            return [
              pixel.r.toDouble(),
              pixel.g.toDouble(),
              pixel.b.toDouble(),
            ];
          },
        ),
      ),
    );

    final output = List.generate(1, (_) => List.filled(_labels.length, 0.0));
    final inputTensor = _interpreter!.getInputTensors().first;
    final outputTensor = _interpreter!.getOutputTensors().first;
    try {
      _interpreter!.run(input, output);
    } catch (error, stackTrace) {
      debugPrint(
        'TFLite inference failed for $_modelAsset: '
        'input ${inputTensor.shape}/${inputTensor.type}, '
        'output ${outputTensor.shape}/${outputTensor.type}: $error',
      );
      debugPrintStack(stackTrace: stackTrace);
      throw StateError(
        'TFLite inference failed for ${_modelAsset ?? 'unknown model'} '
        '(input ${inputTensor.shape}/${inputTensor.type}, '
        'output ${outputTensor.shape}/${outputTensor.type}): $error',
      );
    }

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
    _modelAsset = null;
    _isInitialized = false;
  }
}
