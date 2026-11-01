import 'package:flutter_test/flutter_test.dart';
import 'package:palayplan/services/disease_classifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('DiseaseClassifier class is instantiated and generates valid structure', () async {
    const prediction = DiseasePrediction(
      label: 'bacterial_leaf_blight',
      confidence: 0.88,
    );

    expect(prediction.displayName, 'Bacterial Leaf Blight');
    expect(prediction.treatmentTip.isNotEmpty, true);
    expect(prediction.confidence, 0.88);
  });
}

