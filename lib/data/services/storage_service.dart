import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/settings_model.dart';

class StorageService {
  static const String _settingsBox = 'settings';
  static const String _settingsKey = 'app_settings';
  static const String _lastTextKey = 'last_text';
  static const String _trialStartKey = 'trial_start';
  static const String _macAddressesKey = 'mac_addresses';

  /// Initialise Hive
  static Future<void> init() async {
    await Hive.initFlutter();
  }

  /// Sauvegarde les paramètres
  Future<void> saveSettings(SettingsModel settings) async {
    final box = await _openBoxWithRetry();
    await box.put(_settingsKey, settings.toJson());
  }

  /// Charge les paramètres
  Future<SettingsModel?> loadSettings() async {
    final box = await _openBoxWithRetry();
    final json = box.get(_settingsKey);
    if (json != null) {
      return SettingsModel.fromJson(Map<String, dynamic>.from(json));
    }
    return null;
  }

  /// Sauvegarde le dernier texte
  Future<void> saveLastText(String text) async {
    final box = await _openBoxWithRetry();
    await box.put(_lastTextKey, text);
  }

  /// Charge le dernier texte
  Future<String?> loadLastText() async {
    final box = await _openBoxWithRetry();
    return box.get(_lastTextKey);
  }

  /// Efface toutes les données
  Future<void> clearAll() async {
    final box = await _openBoxWithRetry();
    await box.clear();
  }

  Future<void> saveTrialStart(DateTime date) async {
    final box = await _openBoxWithRetry();
    await box.put(_trialStartKey, date.toIso8601String());
  }

  Future<DateTime?> loadTrialStart() async {
    final box = await _openBoxWithRetry();
    final value = box.get(_trialStartKey);
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  Future<void> saveMacAddresses(List<String> macs) async {
    final box = await _openBoxWithRetry();
    await box.put(_macAddressesKey, macs);
  }

  Future<List<String>> loadMacAddresses() async {
    final box = await _openBoxWithRetry();
    final value = box.get(_macAddressesKey);
    if (value is List) {
      return value.whereType<String>().toList();
    }
    return [];
  }

  Future<Box> _openBoxWithRetry({int retries = 5}) async {
    for (var attempt = 0; attempt < retries; attempt++) {
      try {
        return await Hive.openBox(_settingsBox);
      } on FileSystemException catch (e) {
        final message = e.osError?.message ?? e.message;
        final isLock = message.contains('lock') || message.contains('temporarily unavailable');
        if (isLock && attempt < retries - 1) {
          await Future.delayed(const Duration(milliseconds: 400));
          continue;
        }
        rethrow;
      }
    }
    return Hive.openBox(_settingsBox);
  }
}
