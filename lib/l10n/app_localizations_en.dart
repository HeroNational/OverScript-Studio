// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'OverScript Studio';

  @override
  String get home => 'Home';

  @override
  String get settings => 'Settings';

  @override
  String get addSource => 'Add Source';

  @override
  String get fullscreen => 'Fullscreen';

  @override
  String get exitFullscreen => 'Exit Fullscreen';

  @override
  String get play => 'Play';

  @override
  String get pause => 'Pause';

  @override
  String get reset => 'Reset';

  @override
  String get speed => 'Speed';

  @override
  String get fontSize => 'Font Size';

  @override
  String get fontColor => 'Font Color';

  @override
  String get backgroundColor => 'Background Color';

  @override
  String get textAlignment => 'Text Alignment';

  @override
  String get left => 'Left';

  @override
  String get center => 'Center';

  @override
  String get right => 'Right';

  @override
  String get justify => 'Justify';

  @override
  String get lineSpacing => 'Line Spacing';

  @override
  String get mirrorMode => 'Mirror Mode';

  @override
  String get mirrorModeDescription =>
      'Flip the prompter horizontally for mirror rigs';

  @override
  String get focusMode => 'Focus Mode';

  @override
  String get toolboxScale => 'Toolbar Scale';

  @override
  String get toolboxTheme => 'Toolbar Theme';

  @override
  String get themeGlass => 'Glass';

  @override
  String get themeModern => 'Modern';

  @override
  String get themeContrast => 'High Contrast';

  @override
  String get loadFile => 'Load File';

  @override
  String get loadTextFile => 'Load Text File';

  @override
  String get loadTextFileDescription => 'Formats: TXT, VTT, SRT';

  @override
  String get loadPdfFile => 'Load PDF File';

  @override
  String get loadPdfFileDescription => 'Format: PDF';

  @override
  String get loadFromYoutube => 'Load from YouTube';

  @override
  String get enterYoutubeUrl => 'Enter YouTube URL';

  @override
  String get youtubeUrlHint => 'https://www.youtube.com/watch?v=...';

  @override
  String get language => 'Language';

  @override
  String get french => 'French';

  @override
  String get english => 'English';

  @override
  String get load => 'Load';

  @override
  String get cancel => 'Cancel';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get subtitlesLoadedSuccessfully => 'Subtitles loaded successfully!';

  @override
  String get failedToLoadSubtitles => 'Failed to load subtitles';

  @override
  String get pasteYourText => 'Paste your text here...';

  @override
  String get welcomeMessage => 'Welcome to Professional Teleprompter';

  @override
  String get welcomeSubtitle =>
      'Load a file, enter your text, or import YouTube subtitles to get started';

  @override
  String get homeHeadline => 'OverScript Studio';

  @override
  String get homeSubtitle => 'Quick imports: files or PDF';

  @override
  String footerCopyright(Object year) {
    return '© $year OverLimits Digital Enterprise';
  }

  @override
  String get footerBy =>
      'Built by Jacobin Fokou for OverLimits Digital Enterprise';

  @override
  String get footerLinkedin => 'LinkedIn';

  @override
  String get footerLinkedinUrl => 'linkedin.com/in/jacobindanielfokou';

  @override
  String get legalCgu => 'Terms of Use';

  @override
  String get appearance => 'Appearance';

  @override
  String get behavior => 'Behavior';

  @override
  String get toolbox => 'Toolbar';

  @override
  String get advanced => 'Advanced';

  @override
  String get close => 'Close';

  @override
  String get save => 'Save';

  @override
  String get fontFamily => 'Font';

  @override
  String get bold => 'Bold';

  @override
  String get italic => 'Italic';

  @override
  String get underline => 'Underline';

  @override
  String get textEditor => 'Text Editor';

  @override
  String get richTextMode => 'Rich Text Mode';

  @override
  String get plainTextMode => 'Plain Text Mode';

  @override
  String get youtubeSubtitles => 'YouTube Subtitles';

  @override
  String get noVideoIdFound => 'No video ID found in URL';

  @override
  String get invalidUrl => 'Invalid URL';

  @override
  String get fetchingSubtitles => 'Fetching subtitles...';

  @override
  String get vertical => 'Vertical';

  @override
  String get horizontal => 'Horizontal';

  @override
  String get toolboxOrientation => 'Toolbar Orientation';

  @override
  String get toggleOrientation => 'Toggle orientation';

  @override
  String get playback => 'Playback';

  @override
  String get speedUnit => 'Speed unit';

  @override
  String get speedUnitPixels => 'Pixels per second';

  @override
  String get speedUnitLines => 'Lines per minute';

  @override
  String get speedUnitWords => 'Words per minute';

  @override
  String get defaultSpeed => 'Default speed';

  @override
  String get countdownSeconds => 'Countdown (seconds)';

  @override
  String get autoFullscreenOnStart => 'Auto fullscreen on start';

  @override
  String get autoFullscreenDescription =>
      'Switch to fullscreen automatically when starting the prompter';

  @override
  String get trialActiveTitle => 'Test period';

  @override
  String trialActiveLabel(Object days) {
    return 'Remaining: $days days';
  }

  @override
  String trialExpiresOn(Object date) {
    return 'Expires on $date';
  }

  @override
  String get trialExpiredTitle => 'Trial expired';

  @override
  String get trialExpiredMessage =>
      'The testing period has ended. Source selection is disabled.';

  @override
  String get theme => 'Theme';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get cameraRecording => 'Camera & recording';

  @override
  String get autoStartCamera => 'Start camera automatically';

  @override
  String get autoStartCameraDescription =>
      'Start video capture after countdown';

  @override
  String get cameraAsBackground => 'Camera as background';

  @override
  String get cameraAsBackgroundDescription =>
      'Show camera behind text (transparent mode)';

  @override
  String get promptOpacity => 'Prompt opacity';

  @override
  String get camera => 'Camera';

  @override
  String get microphone => 'Microphone';

  @override
  String get systemDefault => 'System default';

  @override
  String get builtInCamera => 'Built-in camera';

  @override
  String get externalCamera => 'External camera';

  @override
  String get builtInMic => 'Built-in mic';

  @override
  String get externalMic => 'External mic';

  @override
  String get menu => 'Menu';

  @override
  String get help => 'Help';

  @override
  String get helpPageTitle => 'Help & Support';

  @override
  String get infoOverviewTitle => 'System overview';

  @override
  String get infoOverviewSubtitle =>
      'Environment, storage, and license details at a glance.';

  @override
  String get infoOs => 'OS';

  @override
  String get infoOsVersion => 'OS version';

  @override
  String get infoArchitecture => 'Architecture';

  @override
  String get infoResolution => 'Resolution';

  @override
  String get infoLocale => 'Locale';

  @override
  String get infoRecordingsFolder => 'Recordings folder';

  @override
  String get infoOpenRecordingsFolder => 'Open recordings folder';

  @override
  String get infoVideosCount => 'Videos';

  @override
  String get infoTrial => 'Trial';

  @override
  String get infoMac => 'MAC';

  @override
  String get videosEmpty => 'No recordings found yet';

  @override
  String get videosTab => 'Videos';

  @override
  String get helpWelcomeTitle => 'Welcome to OverScript Studio';

  @override
  String get helpWelcomeDescription =>
      'OverScript Studio is a professional teleprompter designed for content creators, speakers, and video producers. This guide will help you get started.';

  @override
  String get helpGettingStarted => 'Getting Started';

  @override
  String get helpStep1Title => '1. Add Your Content';

  @override
  String get helpStep1Description =>
      'Import a file (TXT, PDF, SRT, YouTube) or paste your text directly to prepare the prompter.';

  @override
  String get helpStep1Cta => 'Add sources';

  @override
  String get helpStep2Title => '2. Customize Settings';

  @override
  String get helpStep2Description =>
      'Adjust font size, speed, colors, mirror mode, and layout in the settings menu.';

  @override
  String get helpStep2Cta => 'Open settings';

  @override
  String get helpStep3Title => '3. Start Recording';

  @override
  String get helpStep3Description =>
      'Press the play button to start the teleprompter and begin recording when you are ready.';

  @override
  String get helpFeaturesTitle => 'Key Features';

  @override
  String get helpFeature1 =>
      'System overview tab with locale-aware details and recording folder shortcut';

  @override
  String get helpFeature2 =>
      'Per-video actions: open in folder, share, or delete recordings';

  @override
  String get helpFeature3 =>
      'Customizable speed, fonts, colors, and mirror mode toggle';

  @override
  String get helpFeature4 => 'Mobile-friendly experience';

  @override
  String get helpFeature5 =>
      'Focus mode and fullscreen controls for distraction-free reading';

  @override
  String get helpSystemRequirementsTitle => 'System Requirements (Windows)';

  @override
  String get helpSystemRequirementsDescription =>
      'For Windows users, video recording requires Visual C++ Redistributable 2013 (x64). If you experience issues with recording:';

  @override
  String get helpDownloadVCRedist => 'Download VC++ Redistributable 2013 x64';

  @override
  String get helpTroubleshootingTitle => 'Troubleshooting';

  @override
  String get helpTroubleshoot1Title => 'Camera not working?';

  @override
  String get helpTroubleshoot1Description =>
      'Check that camera permissions are enabled and no other app is using the camera.';

  @override
  String get helpTroubleshoot2Title => 'Recording not starting?';

  @override
  String get helpTroubleshoot2Description =>
      'On Windows, install VC++ Redistributable 2013 x64 (link above).';

  @override
  String get helpTroubleshoot3Title => 'Text not loading?';

  @override
  String get helpTroubleshoot3Description =>
      'Ensure your file is in a supported format (TXT, VTT, SRT, PDF).';

  @override
  String get helpSupportTitle => 'Support & Contact';

  @override
  String get helpSupportDescription =>
      'For additional help or to report issues, contact us at:';

  @override
  String get helpSupportEmail => 'danieluokof@gmail.com';
}
