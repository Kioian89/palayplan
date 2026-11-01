import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/field_model.dart';

/// Provider for managing the farmer's active field profile.
class FieldProvider extends ChangeNotifier {
  static const _prefKey = 'farmer_field_profile';

  FieldProfile _field = FieldProfile.defaultProfile();
  FieldProfile get field => _field;

  FieldProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_prefKey);
    if (jsonStr != null) {
      try {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        _field = FieldProfile.fromJson(map);
        notifyListeners();
      } catch (_) {
        // Fallback to default
      }
    }
  }

  Future<void> updateField(FieldProfile newProfile) async {
    _field = newProfile;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, jsonEncode(_field.toJson()));
  }

  /// Safe accessor that returns the active field. Falls back to default if provider is absent.
  static FieldProfile fieldOf(BuildContext context) {
    try {
      return Provider.of<FieldProvider>(context, listen: true).field;
    } catch (_) {
      return FieldProfile.defaultProfile();
    }
  }

  /// Rebuilds the widget when the field profile changes.
  static FieldProvider watch(BuildContext context) =>
      Provider.of<FieldProvider>(context);

  /// Access without listening.
  static FieldProvider of(BuildContext context) =>
      Provider.of<FieldProvider>(context, listen: false);
}

