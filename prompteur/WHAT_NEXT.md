# What's Next - Prompteur Pro

## 🎯 Fonctionnalités Planifiées

### 1. Synchronisation Voix-Texte (Priorité Haute)

#### Objectif
Permettre au prompteur de suivre automatiquement la lecture en se synchronisant avec la voix de l'utilisateur.

#### Fonctionnalités Détaillées

**1.1 Capture Audio**
- Utiliser le microphone pour capter la voix de l'utilisateur en temps réel
- Package Flutter recommandé: `speech_to_text` ou `flutter_sound`
- Support macOS, Windows, Linux

**1.2 Reconnaissance Vocale**
- Conversion voix → texte en temps réel (STT - Speech-to-Text)
- Options d'implémentation:
  - **Option A**: API locale (plus rapide, offline)
    - macOS: Speech Framework natif
    - Windows: Windows Speech Recognition
    - Multiplateforme: Vosk, Whisper.cpp
  - **Option B**: API Cloud (plus précis)
    - Google Cloud Speech-to-Text
    - Azure Speech Services
    - OpenAI Whisper API

**1.3 Algorithme de Synchronisation**
- Matcher le texte reconnu avec le contenu du prompteur
- Techniques possibles:
  - **Fuzzy matching** (distance de Levenshtein)
  - **N-gram matching** pour tolérer les erreurs de reconnaissance
  - **Fenêtre glissante** pour suivre la progression

**1.4 Défilement Automatique Adaptatif**
- Ajuster la vitesse de défilement en fonction du rythme de lecture
- Calculer la vitesse moyenne de lecture (mots/minute)
- Accélération/ralentissement fluide sans à-coups

**1.5 Indicateur Visuel**
- Surligner le mot/phrase en cours de lecture
- Afficher une barre de progression synchronisée
- Indicateur de confiance de la reconnaissance vocale

#### Architecture Technique

```dart
// Structure de données proposée
class VoiceSyncState {
  bool isListening;
  double confidence;        // Confiance de la reconnaissance (0-1)
  int currentWordIndex;     // Position actuelle dans le texte
  double readingSpeed;      // Vitesse en mots/minute
  List<SyncedWord> words;   // Mots avec timestamps
}

class SyncedWord {
  String text;
  int startIndex;
  int endIndex;
  DateTime timestamp;
  double confidence;
}
```

#### Implémentation par Phases

**Phase 1: Reconnaissance Vocale Basique**
- Intégrer `speech_to_text`
- Afficher le texte reconnu en temps réel
- Bouton pour activer/désactiver l'écoute

**Phase 2: Matching Simple**
- Comparer le texte reconnu avec le contenu
- Détecter la position approximative
- Défilement manuel vers la position détectée

**Phase 3: Synchronisation Avancée**
- Suivi en temps réel
- Défilement automatique adaptatif
- Gestion des pauses et reprises

**Phase 4: Optimisations**
- Mise en cache des patterns fréquents
- Calibration personnalisée par utilisateur
- Support multilingue

#### Paramètres Utilisateur à Ajouter

```dart
// Dans SettingsModel
class VoiceSyncSettings {
  bool enableVoiceSync;           // Activer/désactiver
  String recognitionLanguage;     // Langue de reconnaissance
  double minimumConfidence;       // Seuil de confiance (0.5-1.0)
  bool highlightCurrentWord;      // Surligner le mot actuel
  bool autoScrollWithVoice;       // Défilement automatique
  double syncSensitivity;         // Réactivité (0-1)
  bool showConfidenceIndicator;   // Afficher la confiance
}
```

#### Interface Utilisateur

**Nouveaux Contrôles dans la Toolbox:**
- Bouton micro (activer/désactiver l'écoute)
- Indicateur LED pour l'état de reconnaissance
- Affichage de la confiance de synchronisation

**Nouveau Panneau de Paramètres:**
- Section "Synchronisation Vocale"
  - Toggle activation
  - Sélection de la langue
  - Slider de sensibilité
  - Calibration du micro
  - Test de reconnaissance

#### Défis Techniques

1. **Latence**: Minimiser le délai entre voix et synchronisation
2. **Précision**: Gérer les accents, bruits de fond, erreurs de prononciation
3. **Performance**: Traitement temps réel sans ralentir l'UI
4. **Permissions**: Accès micro sur macOS/Windows/Linux
5. **Offline vs Online**: Balance entre précision et vie privée

#### Packages Flutter Recommandés

```yaml
dependencies:
  # Reconnaissance vocale
  speech_to_text: ^7.0.0

  # Alternative pour plus de contrôle
  flutter_sound: ^9.11.3

  # Matching de texte
  fuzzy: ^0.5.1

  # Analyse de similarité
  string_similarity: ^2.0.0

  # Permissions
  permission_handler: ^11.3.1
```

---

### 2. Autres Fonctionnalités Futures

#### 2.1 Contrôle à Distance
- Télécommande mobile (smartphone comme remote)
- Support Bluetooth clavier/pédale
- Intégration avec Stream Deck

#### 2.2 Modes d'Affichage Avancés
- Mode miroir (inversé horizontalement pour utilisation avec miroir)
- Mode multi-écran (texte sur un écran, contrôles sur l'autre)
- Mode téléprompter présidentiel (deux écrans latéraux)

#### 2.3 Collaboration
- Synchronisation multi-utilisateurs
- Annotations en temps réel
- Partage de scripts via cloud

#### 2.4 Analytiques
- Statistiques de lecture (durée, vitesse moyenne)
- Historique des sessions
- Export des métriques

#### 2.5 Intelligence Artificielle
- Suggestions de reformulation
- Détection des pauses naturelles
- Génération automatique de scripts à partir de notes

#### 2.6 Accessibilité
- Support lecteur d'écran
- Contraste élevé
- Agrandissement de zones spécifiques

---

## 📝 Notes d'Implémentation

### Priorité Immédiate: Synchronisation Vocale

**Étape 1 (1-2 semaines)**
- Recherche et choix de la solution STT
- Proof of concept avec `speech_to_text`
- Tests de précision sur différents accents

**Étape 2 (2-3 semaines)**
- Implémentation du matching de texte
- Interface utilisateur pour les contrôles vocaux
- Tests avec différents types de contenu

**Étape 3 (2-3 semaines)**
- Optimisation de la synchronisation
- Paramètres utilisateur
- Tests utilisateurs réels

**Étape 4 (1 semaine)**
- Documentation
- Tutoriel vidéo
- Release beta

### Considérations Techniques

**Permissions macOS:**
```xml
<!-- À ajouter dans Info.plist -->
<key>NSMicrophoneUsageDescription</key>
<string>Le prompteur a besoin d'accéder au microphone pour synchroniser le défilement avec votre voix.</string>
```

**Permissions Windows/Linux:**
- Géré automatiquement par `speech_to_text`

---

## 🚀 Roadmap

- [ ] **v1.0** - Version actuelle (complète)
- [ ] **v1.1** - Synchronisation vocale basique
- [ ] **v1.2** - Synchronisation vocale avancée + highlighting
- [ ] **v1.3** - Contrôle à distance
- [ ] **v2.0** - Features collaboratives et cloud
- [ ] **v2.5** - Intelligence artificielle
- [ ] **v3.0** - Plateforme complète (web, mobile)

---

## 💡 Idées en Vrac

- Mode "practice" avec enregistrement et playback
- Traduction en temps réel
- Support pour scripts avec notes/indications
- Intégration avec outils de présentation (PowerPoint, Keynote)
- Mode "confidence monitor" (affichage des diapositives suivantes)
- Générateur de QR code pour partage rapide
- Support pour formats de scripts TV/cinéma (Fountain, Final Draft)

---

## 📚 Ressources Utiles

### Documentation
- [speech_to_text plugin](https://pub.dev/packages/speech_to_text)
- [Vosk Offline Recognition](https://alphacephei.com/vosk/)
- [OpenAI Whisper](https://github.com/openai/whisper)

### Inspiration
- [Teleprompter Premium (iOS)](https://apps.apple.com/us/app/teleprompter-premium/id448620076)
- [PromptSmart (Multi-platform)](https://promptsmart.com/)

### Algorithmes
- [Levenshtein Distance](https://en.wikipedia.org/wiki/Levenshtein_distance)
- [Smith-Waterman Algorithm](https://en.wikipedia.org/wiki/Smith%E2%80%93Waterman_algorithm)
- [Dynamic Time Warping](https://en.wikipedia.org/wiki/Dynamic_time_warping)

---

**Dernière mise à jour:** 2025-11-29
**Mainteneur:** Prompteur Pro Team
