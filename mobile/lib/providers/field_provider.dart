import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/field_model.dart';

/// Provider for managing the farmer's active rice fields and multi-field profiles.
class FieldProvider extends ChangeNotifier {
  static const _prefKey = 'farmer_field_profile';
  static const _listPrefKey = 'farmer_fields_list';
  static const _activeIdxPrefKey = 'farmer_active_field_index';

  List<FieldProfile> _fields = [FieldProfile.defaultProfile()];
  int _activeFieldIndex = 0;

  FieldProfile get field => _fields.isNotEmpty
      ? _fields[_activeFieldIndex.clamp(0, _fields.length - 1)]
      : FieldProfile.defaultProfile();

  List<FieldProfile> get allFields => List.unmodifiable(_fields);
  int get activeFieldIndex => _activeFieldIndex;
  int get fieldCount => _fields.length;

  FieldProvider() {
    load();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final listJsonStr = prefs.getString(_listPrefKey);
    if (listJsonStr != null) {
      try {
        final decoded = jsonDecode(listJsonStr) as List<dynamic>;
        final loaded = decoded
            .map((item) => FieldProfile.fromJson(item as Map<String, dynamic>))
            .toList();
        if (loaded.isNotEmpty) {
          _fields = loaded;
          final savedIdx = prefs.getInt(_activeIdxPrefKey) ?? 0;
          _activeFieldIndex = savedIdx.clamp(0, _fields.length - 1);
          notifyListeners();
          return;
        }
      } catch (_) {
        // Fallback to single field check below
      }
    }

    final jsonStr = prefs.getString(_prefKey);
    if (jsonStr != null) {
      try {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        _fields = [FieldProfile.fromJson(map)];
        _activeFieldIndex = 0;
        notifyListeners();
      } catch (_) {
        // Leave defaults untouched
      }
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _listPrefKey,
      jsonEncode(_fields.map((f) => f.toJson()).toList()),
    );
    await prefs.setInt(_activeIdxPrefKey, _activeFieldIndex);
    // Maintain backwards compatibility for single-field reader
    await prefs.setString(_prefKey, jsonEncode(field.toJson()));
  }

  /// Switch the active field being viewed across all screens.
  Future<void> selectField(int index) async {
    if (index >= 0 && index < _fields.length && index != _activeFieldIndex) {
      _activeFieldIndex = index;
      notifyListeners();
      await _save();
    }
  }

  /// Add a new field profile and make it the active selection.
  Future<void> addField(FieldProfile newProfile) async {
    _fields.add(newProfile);
    _activeFieldIndex = _fields.length - 1;
    notifyListeners();
    await _save();
  }

  /// Update the current active field profile.
  Future<void> updateField(FieldProfile newProfile) async {
    if (_fields.isEmpty) {
      _fields = [newProfile];
      _activeFieldIndex = 0;
    } else {
      _fields[_activeFieldIndex.clamp(0, _fields.length - 1)] = newProfile;
    }
    notifyListeners();
    await _save();
  }

  /// Update a specific field profile by index.
  Future<void> updateFieldAt(int index, FieldProfile updatedProfile) async {
    if (index >= 0 && index < _fields.length) {
      _fields[index] = updatedProfile;
      notifyListeners();
      await _save();
    }
  }

  /// Delete a field profile. (Guarantees at least 1 field remains).
  Future<bool> deleteField(int index) async {
    if (_fields.length <= 1) return false;
    if (index >= 0 && index < _fields.length) {
      _fields.removeAt(index);
      if (_activeFieldIndex >= _fields.length) {
        _activeFieldIndex = _fields.length - 1;
      }
      notifyListeners();
      await _save();
      return true;
    }
    return false;
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
