# OverScript Studio

Téléprompteur desktop (Flutter) pour macOS et Windows. Éditeur riche (Quill), import SRT/VTT/TXT/PDF, positions de toolbox configurables, thèmes, compte à rebours, plein écran, stockage local (Hive), focus mode, i18n (fr/en).

## Installation & lancement
- Dépôts : Flutter 3.19+ recommandé.
- Dépendances : `flutter pub get`
- Dev (macOS/Windows) : `flutter run -d macos` ou `flutter run -d windows`

### Builds
- macOS Release : `flutter build macos --release` → `build/macos/Build/Products/Release/OverScript Studio.app`
- Windows Release : `flutter build windows --release` → `build/windows/runner/Release/OverScript Studio.exe`
- Icônes : macOS (`macos/Runner/Assets.xcassets/AppIcon.appiconset`), Windows (`windows/runner/resources/app_icon.ico` + `Runner.rc`). Optionnellement `flutter_launcher_icons` en dev.

## Fonctionnalités
- Éditeur WYSIWYG (gras, italique, listes, alignements) et import texte brut.
- Import sous-titres SRT/VTT avec nettoyage métadonnées ; import PDF (rendu image).
- Toolbox positionnable (haut/bas/latéral), thèmes glass/modern/contrast, échelle ajustable.
- Compte à rebours configurable, timers optionnels, plein écran, focus mode.
- Raccourcis : Espace (lecture/pause), F (plein écran), Échap (quitter plein écran), ↑/↓ (vitesse), R (reset).
- Localisation fr/en (l10n).

## Structure
- `lib/main.dart` : bootstrap, theming, home.
- `lib/presentation/screens` : UI (prompter, settings, sources).
- `lib/presentation/providers` : Riverpod (playback, settings).
- `lib/data/services` : stockage (Hive), PDF, YouTube subtitles (non utilisé si désactivé), etc.
- `assets/` : textures bannière, CGU.

## CGU
Document Markdown : `assets/cgu.md`, affiché via `CguPage`.

## Contrib
- Codegen : `flutter pub run build_runner build --delete-conflicting-outputs`
- Lints : `flutter analyze`
- Tests : `flutter test`
