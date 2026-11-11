import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/field_model.dart';

/// Provider for managing the farmer's active rice fields and multi-field profiles.
class FieldProvider extends ChangeNotifier {
  static const _prefKey = 'farmer_field_profile';
  static const _listPrefKey = 'farmer_fields_list';
  static const _activeIdxPrefKey = 'farmer_active_field_index';
  static const _legacyMigrationPrefKey = 'farmer_fields_migrated_to_firebase';

  FieldProvider({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth,
        _firestore = firestore,
        _userId = auth?.currentUser?.uid {
    _authSubscription = _auth?.authStateChanges().listen(
      (user) => _changeUser(user?.uid),
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('Firebase auth state error: $error');
      },
    );
    unawaited(load());
  }

  final FirebaseAuth? _auth;
  final FirebaseFirestore? _firestore;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _firestoreSubscription;
  String? _userId;
  int _loadGeneration = 0;
  String? _cloudSyncError;

  List<FieldProfile> _fields = [FieldProfile.defaultProfile()];
  int _activeFieldIndex = 0;

  FieldProfile get field => _fields.isNotEmpty
      ? _fields[_activeFieldIndex.clamp(0, _fields.length - 1)]
      : FieldProfile.defaultProfile();

  List<FieldProfile> get allFields => List.unmodifiable(_fields);
  int get activeFieldIndex => _activeFieldIndex;
  int get fieldCount => _fields.length;
  String? get cloudSyncError => _cloudSyncError;

  DocumentReference<Map<String, dynamic>> _cloudDocument(String uid) =>
      _firestore!
          .collection('users')
          .doc(uid)
          .collection('appData')
          .doc('fieldProfiles');

  Future<void> load() async {
    final generation = ++_loadGeneration;
    final uid = _userId;
    final prefs = await SharedPreferences.getInstance();
    var stored = await _readLocal(prefs, uid);

    if (generation != _loadGeneration) return;

    if (uid != null && _firestore != null) {
      _applyStored(stored ?? _StoredFields.defaults());
      notifyListeners();

      try {
        final snapshot = await _cloudDocument(uid).get();
        if (generation != _loadGeneration) return;

        if (snapshot.exists) {
          stored = _StoredFields.fromJson(snapshot.data()!);
          _applyStored(stored);
          await _writeLocal(prefs, uid, stored);
          _cloudSyncError = null;
        } else {
          stored ??= await _readLegacyIfAvailable(prefs);
          if (stored != null) {
            _applyStored(stored);
            await _writeLocal(prefs, uid, stored);
            _queueCloudWrite(uid, stored);
            if (prefs.getBool(_legacyMigrationPrefKey) != true) {
              await prefs.setBool(_legacyMigrationPrefKey, true);
            }
          }
        }
        _listenForCloudChanges(uid);
      } catch (error, stackTrace) {
        debugPrint('Could not load field profiles from Firestore: $error');
        debugPrintStack(stackTrace: stackTrace);
        _cloudSyncError = error.toString();
        if (stored == null) {
          stored = await _readLegacyIfAvailable(prefs);
          if (stored != null) {
            _applyStored(stored);
            await _writeLocal(prefs, uid, stored);
            _queueCloudWrite(uid, stored);
            await prefs.setBool(_legacyMigrationPrefKey, true);
          }
        }
        _listenForCloudChanges(uid);
      }

      if (generation != _loadGeneration) return;
      if (stored != null) _applyStored(stored);
      notifyListeners();
      return;
    }

    _applyStored(stored ?? _StoredFields.defaults());
    notifyListeners();
  }

  Future<_StoredFields?> _readLegacyIfAvailable(
    SharedPreferences prefs,
  ) async {
    if (prefs.getBool(_legacyMigrationPrefKey) == true) return null;
    return _readLocal(prefs, null);
  }

  Future<_StoredFields?> _readLocal(
    SharedPreferences prefs,
    String? uid,
  ) async {
    final suffix = uid == null ? '' : '_$uid';
    final listJson = prefs.getString('$_listPrefKey$suffix');
    if (listJson != null) {
      try {
        final decoded = jsonDecode(listJson) as List<dynamic>;
        final fields = decoded
            .map((item) => FieldProfile.fromJson(item as Map<String, dynamic>))
            .toList();
        if (fields.isNotEmpty) {
          final index =
              (prefs.getInt('$_activeIdxPrefKey$suffix') ?? 0)
                  .clamp(0, fields.length - 1);
          return _StoredFields(fields, index);
        }
      } catch (error, stackTrace) {
        debugPrint('Could not read locally saved field list: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
    }

    final profileJson = prefs.getString('$_prefKey$suffix');
    if (profileJson != null) {
      try {
        final profile =
            FieldProfile.fromJson(jsonDecode(profileJson) as Map<String, dynamic>);
        return _StoredFields([profile], 0);
      } catch (error, stackTrace) {
        debugPrint('Could not read locally saved field profile: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
    }
    return null;
  }

  void _applyStored(_StoredFields stored) {
    if (stored.fields.isEmpty) {
      _fields = [FieldProfile.defaultProfile()];
      _activeFieldIndex = 0;
      return;
    }
    _fields = stored.fields;
    _activeFieldIndex = stored.activeIndex.clamp(0, _fields.length - 1);
  }

  Future<void> _writeLocal(
    SharedPreferences prefs,
    String? uid,
    _StoredFields stored,
  ) async {
    final suffix = uid == null ? '' : '_$uid';
    await prefs.setString(
      '$_listPrefKey$suffix',
      jsonEncode(stored.fields.map((field) => field.toJson()).toList()),
    );
    await prefs.setInt('$_activeIdxPrefKey$suffix', stored.activeIndex);
    await prefs.setString(
      '$_prefKey$suffix',
      jsonEncode(stored.fields[stored.activeIndex].toJson()),
    );
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = _StoredFields(_fields, _activeFieldIndex);
    final uid = _userId;
    await _writeLocal(prefs, uid, stored);
    if (uid != null && _firestore != null) {
      _queueCloudWrite(uid, stored);
    }
  }

  void _queueCloudWrite(String uid, _StoredFields stored) {
    unawaited(_writeCloud(uid, stored));
  }

  Future<void> _writeCloud(String uid, _StoredFields stored) async {
    try {
      await _cloudDocument(uid).set({
        ...stored.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (_userId == uid) {
        _cloudSyncError = null;
        notifyListeners();
      }
    } catch (error, stackTrace) {
      debugPrint('Could not save field profiles to Firestore: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (_userId == uid) {
        _cloudSyncError = error.toString();
        notifyListeners();
      }
    }
  }

  void _listenForCloudChanges(String uid) {
    unawaited(_firestoreSubscription?.cancel());
    _firestoreSubscription = _cloudDocument(uid).snapshots().listen(
      (snapshot) async {
        if (_userId != uid || !snapshot.exists) return;
        try {
          final stored = _StoredFields.fromJson(snapshot.data()!);
          _applyStored(stored);
          final prefs = await SharedPreferences.getInstance();
          await _writeLocal(prefs, uid, stored);
          _cloudSyncError = null;
          notifyListeners();
        } catch (error, stackTrace) {
          debugPrint('Could not apply Firestore field profile update: $error');
          debugPrintStack(stackTrace: stackTrace);
          _cloudSyncError = error.toString();
          notifyListeners();
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('Firestore field profile listener failed: $error');
        debugPrintStack(stackTrace: stackTrace);
        if (_userId == uid) {
          _cloudSyncError = error.toString();
          notifyListeners();
        }
      },
    );
  }

  Future<void> _changeUser(String? uid) async {
    if (_userId == uid) return;
    _userId = uid;
    _loadGeneration++;
    _cloudSyncError = null;
    await _firestoreSubscription?.cancel();
    _firestoreSubscription = null;
    _fields = [FieldProfile.defaultProfile()];
    _activeFieldIndex = 0;
    notifyListeners();
    await load();
  }

  @override
  void dispose() {
    unawaited(_authSubscription?.cancel());
    unawaited(_firestoreSubscription?.cancel());
    super.dispose();
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

class _StoredFields {
  const _StoredFields(this.fields, this.activeIndex);

  final List<FieldProfile> fields;
  final int activeIndex;

  factory _StoredFields.defaults() =>
      _StoredFields([FieldProfile.defaultProfile()], 0);

  factory _StoredFields.fromJson(Map<String, dynamic> json) {
    final fieldsJson = json['fields'] as List<dynamic>;
    final fields = fieldsJson
        .map((item) => FieldProfile.fromJson(item as Map<String, dynamic>))
        .toList();
    if (fields.isEmpty) {
      throw const FormatException('Firestore field profile list is empty.');
    }
    final activeIndex =
        ((json['activeFieldIndex'] as num?)?.toInt() ?? 0)
            .clamp(0, fields.length - 1);
    return _StoredFields(fields, activeIndex);
  }

  Map<String, dynamic> toJson() => {
        'fields': fields.map((field) => field.toJson()).toList(),
        'activeFieldIndex': activeIndex,
      };
}
