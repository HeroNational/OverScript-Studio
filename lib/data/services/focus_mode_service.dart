import 'dart:io';

/// Gestion simplifiée du mode "ne pas déranger"/Focus.
/// Implémente un no-op par défaut et pourra être remplacé par
/// des intégrations natives (AppleScript, PowerShell, D-Bus).
class FocusModeService {
  Future<void> enable() async {
    // TODO: Implémenter l'activation native (macOS/Windows/Linux).
    // macOS : AppleScript ou API Focus.
    // Windows : Focus Assist.
    // Linux : D-Bus (GNOME/KDE).
    _log('Activation du mode Ne pas déranger (placeholder) sur ${Platform.operatingSystem}');
  }

  Future<void> disable() async {
    _log('Désactivation du mode Ne pas déranger (placeholder) sur ${Platform.operatingSystem}');
  }

  void _log(String message) {
    // ignore: avoid_print
    print('[FocusMode] $message');
  }
}
