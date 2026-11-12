import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supported app languages.
enum AppLanguage { english, filipino, bisaya }

extension AppLanguageExt on AppLanguage {
  String get code {
    switch (this) {
      case AppLanguage.english:  return 'en';
      case AppLanguage.filipino: return 'fil';
      case AppLanguage.bisaya:   return 'ceb';
    }
  }

  String get nativeName {
    switch (this) {
      case AppLanguage.english:  return 'English';
      case AppLanguage.filipino: return 'Filipino';
      case AppLanguage.bisaya:   return 'Bisaya';
    }
  }

  String get flagEmoji {
    // All three are Philippine languages — use PH flag
    return '🇵🇭';
  }
}

/// ChangeNotifier that holds and persists the active language.
class LanguageProvider extends ChangeNotifier {
  static const _prefKey = 'app_language';

  AppLanguage _language = AppLanguage.english;
  AppLanguage get language => _language;

  LanguageProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    if (saved != null) {
      _language = AppLanguage.values.firstWhere(
        (l) => l.code == saved,
        orElse: () => AppLanguage.english,
      );
      notifyListeners();
    }
  }

  Future<void> setLanguage(AppLanguage lang) async {
    if (_language == lang) return;
    _language = lang;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, lang.code);
  }

  /// Convenience static accessor — does NOT listen for changes.
  static LanguageProvider of(BuildContext context) =>
      Provider.of<LanguageProvider>(context, listen: false);

  /// Convenience static accessor that rebuilds the widget on language change.
  static LanguageProvider watch(BuildContext context) =>
      Provider.of<LanguageProvider>(context);

  /// Safely get the active language. If LanguageProvider is not in the widget tree
  /// (e.g. in standalone widget tests), falls back to [AppLanguage.english].
  static AppLanguage languageOf(BuildContext context) {
    try {
      final provider = Provider.of<LanguageProvider>(context, listen: true);
      return provider.language;
    } catch (_) {
      return AppLanguage.english;
    }
  }
}

