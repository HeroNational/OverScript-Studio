import 'package:hive_flutter/hive_flutter.dart';
import '../models/settings_model.dart';

class StorageService {
  static const String _settingsBox = 'settings';
  static const String _settingsKey = 'app_settings';
  static const String _lastTextKey = 'last_text';

  /// Initialise Hive
  static Future<void> init() async {
    await Hive.initFlutter();
  }

  /// Sauvegarde les paramètres
  Future<void> saveSettings(SettingsModel settings) async {
    final box = await Hive.openBox(_settingsBox);
    await box.put(_settingsKey, settings.toJson());
  }

  /// Charge les paramètres
  Future<SettingsModel?> loadSettings() async {
    final box = await Hive.openBox(_settingsBox);
    final json = box.get(_settingsKey);
    if (json != null) {
      return SettingsModel.fromJson(Map<String, dynamic>.from(json));
    }
    return null;
  }

  /// Sauvegarde le dernier texte
  Future<void> saveLastText(String text) async {
    final box = await Hive.openBox(_settingsBox);
    await box.put(_lastTextKey, text);
  }

  /// Charge le dernier texte
  Future<String?> loadLastText() async {
    final box = await Hive.openBox(_settingsBox);
    return box.get(_lastTextKey);
  }

  /// Efface toutes les données
  Future<void> clearAll() async {
    final box = await Hive.openBox(_settingsBox);
    await box.clear();
  }
}
