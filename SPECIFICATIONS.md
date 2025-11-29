# Spécifications du Prompteur Professionnel Flutter Desktop

## Vue d'ensemble
Application de prompteur professionnel pour macOS/Windows/Linux développée avec Flutter Desktop, offrant une expérience moderne et personnalisable pour la lecture de scripts.

---

## Fonctionnalités Principales

### 1. Gestion du Texte

#### Import de Fichiers
- **Formats supportés :**
  - Texte brut (`.txt`)
  - Sous-titres (`.vtt`, `.srt`)
  - Documents PDF
- **Copier-coller :** Support du texte formaté avec préservation de la mise en forme

#### Affichage PDF
- Défilement automatique du PDF à vitesse paramétrable
- Rendu natif des pages PDF
- Navigation fluide entre les pages

### 2. Contrôles de Lecture

#### Vitesse
- Réglage de la vitesse de défilement (paramétrable)
- Unités : pixels/seconde ou lignes/minute
- Slider avec ajustement en temps réel

#### Lecture/Pause
- Bouton play/pause
- Pause automatique sur :
  - Mouvement de souris
  - Appui sur touche clavier (configurable)
- Raccourcis clavier personnalisables

### 3. Personnalisation Visuelle

#### Interface Moderne
- **Style :**
  - Bordures arrondies (border radius)
  - Dégradés subtils animés
  - Design épuré et professionnel
  - Animations fluides
- **Icônes :** Police d'icônes professionnelle (Material Icons ou Lucide Icons)
- **Thème :** Personnalisation complète du style de l'interface

#### Texte du Prompteur
- Couleur de fond personnalisable
- Couleur de texte personnalisable
- Sélection de police parmi les polices système installées
- Taille de police ajustable
- Contraste optimisé

### 4. Mode Plein Écran

#### Comportement
- Passage en plein écran manuel
- **Option :** Plein écran automatique au lancement de la lecture (paramétrable)
- Sortie du plein écran : touche Échap

#### Toolbar Flottante
- Toolbar présente en mode plein écran
- Position personnalisable sur l'écran
- Accès aux contrôles essentiels :
  - Play/Pause
  - Vitesse
  - Paramètres rapides
- Auto-masquage possible

### 5. Mode Concentration

#### Intégration Système
- Activation du mode "Ne pas déranger" / "Focus" du système d'exploitation
- **Déclenchement :** Au lancement du prompting
- **Configuration :** Activable/désactivable dans les paramètres
- Support multi-plateforme :
  - macOS : Focus Mode API
  - Windows : Focus Assist
  - Linux : Do Not Disturb

### 6. Persistance des Données

#### Sauvegarde Automatique
- Tous les paramètres de l'application sauvegardés
- Scripts récents mémorisés
- Position de lecture sauvegardée
- Préférences utilisateur persistantes

#### Données Sauvegardées
- Derniers fichiers ouverts
- Configuration de vitesse
- Couleurs et polices
- Position de la toolbar
- État du mode plein écran auto
- Raccourcis clavier personnalisés

---

## Architecture Technique

### Stack Technologique
- **Framework :** Flutter 3.x
- **Plateforme :** Desktop (macOS, Windows, Linux)
- **Stockage :** shared_preferences / hive
- **PDF :** syncfusion_flutter_pdf / pdf_render
- **Polices système :** google_fonts + system fonts
- **Gestion d'état :** Provider / Riverpod

### Structure du Projet

```
lib/
├── main.dart
├── app.dart
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_dimensions.dart
│   │   └── app_text_styles.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── gradient_config.dart
│   └── utils/
│       ├── file_helper.dart
│       └── system_integration.dart
│
├── data/
│   ├── models/
│   │   ├── script_model.dart
│   │   ├── settings_model.dart
│   │   └── playback_state.dart
│   ├── repositories/
│   │   ├── settings_repository.dart
│   │   └── script_repository.dart
│   └── services/
│       ├── file_import_service.dart
│       ├── pdf_service.dart
│       ├── storage_service.dart
│       └── focus_mode_service.dart
│
├── presentation/
│   ├── providers/
│   │   ├── settings_provider.dart
│   │   ├── playback_provider.dart
│   │   └── script_provider.dart
│   ├── screens/
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   └── widgets/
│   │   ├── editor/
│   │   │   ├── editor_screen.dart
│   │   │   └── widgets/
│   │   ├── prompter/
│   │   │   ├── prompter_screen.dart
│   │   │   └── widgets/
│   │   │       ├── text_display.dart
│   │   │       ├── pdf_display.dart
│   │   │       └── floating_toolbar.dart
│   │   └── settings/
│   │       ├── settings_screen.dart
│   │       └── widgets/
│   └── widgets/
│       ├── common/
│       │   ├── gradient_button.dart
│       │   ├── animated_container.dart
│       │   └── custom_slider.dart
│       └── controls/
│           ├── playback_controls.dart
│           └── speed_control.dart
│
└── l10n/
    └── app_localizations.dart
```

---

## Spécifications Détaillées

### Import de Fichiers

#### TXT
- Encodage UTF-8
- Préservation des retours à la ligne
- Support des tabulations

#### VTT/SRT
- Parsing des timestamps
- Affichage séquentiel des sous-titres
- Option : afficher ou masquer les timestamps

#### PDF
- Rendu page par page
- Zoom adaptatif à la largeur de l'écran
- Défilement vertical continu

### Contrôles Clavier

#### Raccourcis par Défaut
- `Space` : Play/Pause
- `↑` : Augmenter vitesse
- `↓` : Diminuer vitesse
- `Esc` : Sortir du plein écran
- `F` : Basculer plein écran
- `R` : Reset position

#### Configuration
- Tous les raccourcis personnalisables
- Détection de conflits
- Enregistrement des combinaisons

### Personnalisation Interface

#### Paramètres Disponibles
- Schéma de couleurs (presets + personnalisé)
- Intensité des dégradés
- Vitesse des animations
- Radius des bordures
- Opacité de la toolbar

#### Presets de Style
- Mode Moderne (défaut)
- Mode Minimaliste
- Mode Haute Visibilité
- Mode Personnalisé

### Toolbar Flottante

#### Positions
- Haut
- Bas
- Gauche
- Droite
- Personnalisée (drag & drop)

#### Contenu
- Icône Play/Pause
- Slider de vitesse
- Sélecteur de police
- Taille de texte
- Couleurs rapides
- Bouton paramètres
- Bouton plein écran

#### Comportement
- Auto-masquage après X secondes d'inactivité
- Réapparition au survol
- Transparence ajustable

### Persistance

#### Format de Stockage
```json
{
  "settings": {
    "autoFullscreen": true,
    "enableFocusMode": true,
    "defaultSpeed": 120,
    "backgroundColor": "#1a1a1a",
    "textColor": "#ffffff",
    "fontFamily": "Roboto",
    "fontSize": 48,
    "toolbarPosition": "bottom",
    "pauseOnMouseMove": true,
    "pauseKey": "Space"
  },
  "recentFiles": [
    {
      "path": "/path/to/script.txt",
      "lastPosition": 1234,
      "lastOpened": "2025-11-29T12:00:00Z"
    }
  ]
}
```

### Mode Focus

#### Implémentation par Plateforme

**macOS :**
```dart
// Utiliser focus_mode ou platform channels
// Activer Focus Mode via AppleScript ou API native
```

**Windows :**
```dart
// Focus Assist via Windows API
// Notifications silencieuses
```

**Linux :**
```dart
// D-Bus notifications
// Do Not Disturb via desktop environment
```

---

## Interface Utilisateur

### Écran d'Accueil
- Bouton "Nouveau Script"
- Bouton "Importer Fichier"
- Liste des scripts récents avec aperçu
- Accès rapide aux paramètres

### Écran Éditeur
- Zone de texte avec formatage
- Toolbar de mise en forme
- Aperçu du rendu prompteur
- Stats (mots, temps estimé)
- Bouton "Démarrer Prompteur"

### Écran Prompteur
- Texte/PDF plein écran
- Toolbar flottante
- Indicateur de vitesse subtil
- Barre de progression (optionnelle)

### Écran Paramètres
- Sections organisées :
  - Lecture
  - Apparence
  - Contrôles
  - Système
  - Avancé

---

## Design System

### Palette de Couleurs
- Primaire : Gradient moderne (bleu/violet)
- Secondaire : Accent subtil
- Fond : Dark/Light adaptable
- Texte : Haute lisibilité

### Typographie
- Titres : Police système bold
- Texte : Police système regular
- Prompteur : Polices système au choix

### Espacements
- Padding : 8, 16, 24, 32px
- Radius : 8, 12, 16, 24px
- Gaps : 8, 12, 16px

### Animations
- Duration : 200-400ms
- Curves : easeInOut, fastOutSlowIn
- Transitions fluides entre états

---

## Priorisation

### MVP (Version 1.0)
1. Import TXT et copier-coller
2. Défilement avec vitesse ajustable
3. Play/Pause
4. Personnalisation couleurs et police
5. Plein écran
6. Persistance basique

### Version 1.1
1. Import VTT/SRT
2. Toolbar flottante
3. Plein écran automatique
4. Raccourcis personnalisables
5. Pause sur mouvement souris

### Version 1.2
1. Import PDF
2. Mode Focus système
3. Thèmes prédefinis
4. Polices système complètes

### Version 2.0
1. Contrôle à distance
2. Multi-écrans
3. Statistiques avancées
4. Export de sessions

---

## Contraintes et Considérations

### Performance
- Rendu fluide à 60 FPS minimum
- Import rapide de gros fichiers PDF
- Mémoire optimisée pour PDF volumineux

### Accessibilité
- Support lecteur d'écran
- Contrastes WCAG AAA
- Navigation clavier complète

### Compatibilité
- macOS 10.14+
- Windows 10+
- Linux (Ubuntu 20.04+)

---

## Tests

### Tests Unitaires
- Services d'import
- Calculs de vitesse
- Gestion d'état

### Tests d'Intégration
- Flow complet d'import
- Sauvegarde/restauration
- Contrôles de lecture

### Tests UI
- Navigation
- Responsive design
- Animations

---

## Documentation Utilisateur

### Guide de Démarrage Rapide
1. Importer ou coller un texte
2. Ajuster la vitesse
3. Personnaliser l'apparence
4. Lancer le prompteur

### Raccourcis Clavier
- Liste complète
- Configuration personnalisée

### FAQ
- Formats supportés
- Problèmes courants
- Optimisation performance

---

## Roadmap Future

- Support vidéo avec sous-titres sync
- Collaboration en temps réel
- Cloud sync des scripts
- Application mobile companion
- Support télécommande Bluetooth
- IA pour estimation vocale
- Mode répétition avec enregistrement

---

**Version du document :** 1.0
**Date :** 29 Novembre 2025
**Auteur :** Spécifications Prompteur Pro
