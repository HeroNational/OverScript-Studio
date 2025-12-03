// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'OverScript Studio';

  @override
  String get home => 'Accueil';

  @override
  String get settings => 'Paramètres';

  @override
  String get addSource => 'Ajouter une source';

  @override
  String get fullscreen => 'Plein écran';

  @override
  String get exitFullscreen => 'Quitter le plein écran';

  @override
  String get play => 'Lecture';

  @override
  String get pause => 'Pause';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get speed => 'Vitesse';

  @override
  String get fontSize => 'Taille de police';

  @override
  String get fontColor => 'Couleur de police';

  @override
  String get backgroundColor => 'Couleur de fond';

  @override
  String get textAlignment => 'Alignement du texte';

  @override
  String get left => 'Gauche';

  @override
  String get center => 'Centre';

  @override
  String get right => 'Droite';

  @override
  String get justify => 'Justifié';

  @override
  String get lineSpacing => 'Interligne';

  @override
  String get mirrorMode => 'Mode miroir';

  @override
  String get focusMode => 'Mode focus';

  @override
  String get toolboxScale => 'Échelle de la barre d\'outils';

  @override
  String get toolboxTheme => 'Thème de la barre d\'outils';

  @override
  String get themeGlass => 'Verre';

  @override
  String get themeModern => 'Moderne';

  @override
  String get themeContrast => 'Contraste élevé';

  @override
  String get loadFile => 'Charger un fichier';

  @override
  String get loadTextFile => 'Charger un fichier texte';

  @override
  String get loadTextFileDescription => 'Formats: TXT, VTT, SRT';

  @override
  String get loadPdfFile => 'Charger un fichier PDF';

  @override
  String get loadPdfFileDescription => 'Format: PDF';

  @override
  String get loadFromYoutube => 'Charger depuis YouTube';

  @override
  String get enterYoutubeUrl => 'Entrez l\'URL YouTube';

  @override
  String get youtubeUrlHint => 'https://www.youtube.com/watch?v=...';

  @override
  String get language => 'Langue';

  @override
  String get french => 'Français';

  @override
  String get english => 'Anglais';

  @override
  String get load => 'Charger';

  @override
  String get cancel => 'Annuler';

  @override
  String get loading => 'Chargement...';

  @override
  String get error => 'Erreur';

  @override
  String get success => 'Succès';

  @override
  String get subtitlesLoadedSuccessfully => 'Sous-titres chargés avec succès !';

  @override
  String get failedToLoadSubtitles => 'Impossible de récupérer les sous-titres';

  @override
  String get pasteYourText => 'Collez votre texte ici...';

  @override
  String get welcomeMessage => 'Bienvenue dans OverScript Studio';

  @override
  String get welcomeSubtitle =>
      'Chargez un fichier ou entrez votre texte pour commencer';

  @override
  String get homeHeadline => 'OverScript Studio';

  @override
  String get homeSubtitle => 'Imports rapides : fichiers ou PDF';

  @override
  String footerCopyright(Object year) {
    return '© $year OverLimits Digital Enterprise';
  }

  @override
  String get footerBy =>
      'Réalisé par Jacobin Fokou pour OverLimits Digital Enterprise';

  @override
  String get footerLinkedin => 'LinkedIn';

  @override
  String get footerLinkedinUrl => 'linkedin.com/in/jacobindanielfokou';

  @override
  String get legalCgu => 'CGU';

  @override
  String get appearance => 'Apparence';

  @override
  String get behavior => 'Comportement';

  @override
  String get toolbox => 'Barre d\'outils';

  @override
  String get advanced => 'Avancé';

  @override
  String get close => 'Fermer';

  @override
  String get save => 'Enregistrer';

  @override
  String get fontFamily => 'Police';

  @override
  String get bold => 'Gras';

  @override
  String get italic => 'Italique';

  @override
  String get underline => 'Souligné';

  @override
  String get textEditor => 'Éditeur de texte';

  @override
  String get richTextMode => 'Mode texte enrichi';

  @override
  String get plainTextMode => 'Mode texte simple';

  @override
  String get youtubeSubtitles => 'Sous-titres YouTube';

  @override
  String get noVideoIdFound => 'Aucun ID de vidéo trouvé dans l\'URL';

  @override
  String get invalidUrl => 'URL invalide';

  @override
  String get fetchingSubtitles => 'Récupération des sous-titres...';

  @override
  String get vertical => 'Vertical';

  @override
  String get horizontal => 'Horizontal';

  @override
  String get toolboxOrientation => 'Orientation de la barre d\'outils';

  @override
  String get toggleOrientation => 'Changer l\'orientation';

  @override
  String get playback => 'Lecture';

  @override
  String get speedUnit => 'Unité de vitesse';

  @override
  String get speedUnitPixels => 'Pixels par seconde';

  @override
  String get speedUnitLines => 'Lignes par minute';

  @override
  String get speedUnitWords => 'Mots par minute';

  @override
  String get defaultSpeed => 'Vitesse par défaut';

  @override
  String get countdownSeconds => 'Compte à rebours (secondes)';

  @override
  String get autoFullscreenOnStart => 'Plein écran au démarrage';

  @override
  String get autoFullscreenDescription =>
      'Passer automatiquement en plein écran au lancement du prompteur';

  @override
  String get trialActiveTitle => 'Période de test';

  @override
  String trialActiveLabel(Object days) {
    return 'Restant : $days jours';
  }

  @override
  String trialExpiresOn(Object date) {
    return 'Expiration le $date';
  }

  @override
  String get trialExpiredTitle => 'Version d\'essai expirée';

  @override
  String get trialExpiredMessage =>
      'La période de test est terminée. La sélection de sources est désactivée.';

  @override
  String get theme => 'Thème';

  @override
  String get lightMode => 'Mode clair';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get cameraRecording => 'Caméra & enregistrement';

  @override
  String get autoStartCamera => 'Lancer la caméra automatiquement';

  @override
  String get autoStartCameraDescription =>
      'Démarre la capture vidéo après le compte à rebours';

  @override
  String get cameraAsBackground => 'Caméra en fond du prompteur';

  @override
  String get cameraAsBackgroundDescription =>
      'Affiche la caméra derrière le texte (mode transparent)';

  @override
  String get promptOpacity => 'Opacité du texte';

  @override
  String get camera => 'Caméra';

  @override
  String get microphone => 'Microphone';

  @override
  String get systemDefault => 'Défaut système';

  @override
  String get builtInCamera => 'Caméra intégrée';

  @override
  String get externalCamera => 'Caméra externe';

  @override
  String get builtInMic => 'Micro intégré';

  @override
  String get externalMic => 'Micro externe';

  @override
  String get menu => 'Menu';
}
