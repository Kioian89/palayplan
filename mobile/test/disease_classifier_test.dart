import 'package:flutter_test/flutter_test.dart';
import 'package:palayplan/services/disease_classifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('DiseaseClassifier class is instantiated and generates valid structure', () async {
    const prediction = DiseasePrediction(
      label: 'bacterial_leaf_blight',
      confidence: 0.88,
      candidates: [
        DiseaseCandidate(label: 'bacterial_leaf_blight', confidence: 0.88),
        DiseaseCandidate(label: 'brown_spot', confidence: 0.08),
        DiseaseCandidate(label: 'healthy', confidence: 0.04),
      ],
    );

    expect(prediction.displayName, 'Bacterial Leaf Blight');
    expect(prediction.treatmentTip.isNotEmpty, true);
    expect(prediction.confidence, 0.88);
    expect(prediction.candidates.length, 3);
    expect(prediction.candidates[0].displayName, 'Bacterial Leaf Blight');
    expect(prediction.candidates[2].displayName, 'Healthy Leaf');
  });

  test('Healthy leaf detection provides appropriate display name and tips', () {
    const prediction = DiseasePrediction(
      label: 'healthy',
      confidence: 0.95,
    );

    expect(prediction.displayName, 'Healthy Leaf');
    expect(prediction.treatmentTip, contains('malusog'));
  });
}

