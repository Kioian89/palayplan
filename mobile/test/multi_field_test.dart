import 'package:flutter_test/flutter_test.dart';
import 'package:palayplan/models/field_model.dart';
import 'package:palayplan/providers/field_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Multi-Field Management Logic', () {
    test('Default has 1 field and can add a second custom field', () async {
      final provider = FieldProvider();
      await provider.load();
      expect(provider.fieldCount, 1);
      expect(provider.activeFieldIndex, 0);
      expect(provider.field.fieldName, isEmpty);
      expect(provider.field.isConfigured, isFalse);

      final field2 = FieldProfile(
        fieldName: 'North Parcel',
        municipality: 'Tuguegarao',
        province: 'Cagayan',
        latitude: 17.6132,
        longitude: 121.7270,
        hasCustomCoordinates: true,
        plantingDate: DateTime.now().subtract(const Duration(days: 15)),
        varietyName: 'NSIC Rc 440 (Tubigan 39)',
        daysToMaturity: 112,
        fieldAreaHa: 2.5,
      );

      await provider.addField(field2);

      expect(provider.fieldCount, 2);
      expect(provider.activeFieldIndex, 1);
      expect(provider.field.fieldName, 'North Parcel');
      expect(provider.field.locationDisplay, 'Tuguegarao, Cagayan');

      // Switch back to field 0
      await provider.selectField(0);
      expect(provider.activeFieldIndex, 0);
      expect(provider.field.fieldName, isEmpty);
      expect(provider.field.municipality, isEmpty);

      // Delete field 1
      final deleted = await provider.deleteField(1);
      expect(deleted, isTrue);
      expect(provider.fieldCount, 1);
      expect(provider.field.fieldName, isEmpty);

      // Cannot delete the only remaining field
      final deletedLast = await provider.deleteField(0);
      expect(deletedLast, isFalse);
      expect(provider.fieldCount, 1);
    });

    test('Loads saved multi-field list from SharedPreferences', () async {
      final provider = FieldProvider();

      final customField = FieldProfile(
        fieldName: 'Laguna Paddy',
        municipality: 'Calamba',
        province: 'Laguna',
        latitude: 14.2117,
        longitude: 121.1656,
        plantingDate: DateTime.now(),
      );

      await provider.addField(customField);
      expect(provider.fieldCount, 2);

      // Initialize a new provider instance from saved SharedPreferences
      final reloadedProvider = FieldProvider();
      await reloadedProvider.load();
      expect(reloadedProvider.fieldCount, 2);
      expect(reloadedProvider.allFields[1].fieldName, 'Laguna Paddy');
      expect(reloadedProvider.allFields[1].locationDisplay, 'Calamba, Laguna');
    });
  });
}
