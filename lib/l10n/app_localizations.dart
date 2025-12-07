import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'OverScript Studio'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @addSource.
  ///
  /// In en, this message translates to:
  /// **'Add Source'**
  String get addSource;

  /// No description provided for @fullscreen.
  ///
  /// In en, this message translates to:
  /// **'Fullscreen'**
  String get fullscreen;

  /// No description provided for @exitFullscreen.
  ///
  /// In en, this message translates to:
  /// **'Exit Fullscreen'**
  String get exitFullscreen;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @speed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speed;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSize;

  /// No description provided for @fontColor.
  ///
  /// In en, this message translates to:
  /// **'Font Color'**
  String get fontColor;

  /// No description provided for @backgroundColor.
  ///
  /// In en, this message translates to:
  /// **'Background Color'**
  String get backgroundColor;

  /// No description provided for @textAlignment.
  ///
  /// In en, this message translates to:
  /// **'Text Alignment'**
  String get textAlignment;

  /// No description provided for @left.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get left;

  /// No description provided for @center.
  ///
  /// In en, this message translates to:
  /// **'Center'**
  String get center;

  /// No description provided for @right.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get right;

  /// No description provided for @justify.
  ///
  /// In en, this message translates to:
  /// **'Justify'**
  String get justify;

  /// No description provided for @lineSpacing.
  ///
  /// In en, this message translates to:
  /// **'Line Spacing'**
  String get lineSpacing;

  /// No description provided for @mirrorMode.
  ///
  /// In en, this message translates to:
  /// **'Mirror Mode'**
  String get mirrorMode;

  /// No description provided for @mirrorModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Flip the prompter horizontally for mirror rigs'**
  String get mirrorModeDescription;

  /// No description provided for @focusMode.
  ///
  /// In en, this message translates to:
  /// **'Focus Mode'**
  String get focusMode;

  /// No description provided for @toolboxScale.
  ///
  /// In en, this message translates to:
  /// **'Toolbar Scale'**
  String get toolboxScale;

  /// No description provided for @toolboxTheme.
  ///
  /// In en, this message translates to:
  /// **'Toolbar Theme'**
  String get toolboxTheme;

  /// No description provided for @themeGlass.
  ///
  /// In en, this message translates to:
  /// **'Glass'**
  String get themeGlass;

  /// No description provided for @themeModern.
  ///
  /// In en, this message translates to:
  /// **'Modern'**
  String get themeModern;

  /// No description provided for @themeContrast.
  ///
  /// In en, this message translates to:
  /// **'High Contrast'**
  String get themeContrast;

  /// No description provided for @loadFile.
  ///
  /// In en, this message translates to:
  /// **'Load File'**
  String get loadFile;

  /// No description provided for @loadTextFile.
  ///
  /// In en, this message translates to:
  /// **'Load Text File'**
  String get loadTextFile;

  /// No description provided for @loadTextFileDescription.
  ///
  /// In en, this message translates to:
  /// **'Formats: TXT, VTT, SRT'**
  String get loadTextFileDescription;

  /// No description provided for @loadPdfFile.
  ///
  /// In en, this message translates to:
  /// **'Load PDF File'**
  String get loadPdfFile;

  /// No description provided for @loadPdfFileDescription.
  ///
  /// In en, this message translates to:
  /// **'Format: PDF'**
  String get loadPdfFileDescription;

  /// No description provided for @loadFromYoutube.
  ///
  /// In en, this message translates to:
  /// **'Load from YouTube'**
  String get loadFromYoutube;

  /// No description provided for @enterYoutubeUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter YouTube URL'**
  String get enterYoutubeUrl;

  /// No description provided for @youtubeUrlHint.
  ///
  /// In en, this message translates to:
  /// **'https://www.youtube.com/watch?v=...'**
  String get youtubeUrlHint;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @load.
  ///
  /// In en, this message translates to:
  /// **'Load'**
  String get load;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @subtitlesLoadedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Subtitles loaded successfully!'**
  String get subtitlesLoadedSuccessfully;

  /// No description provided for @failedToLoadSubtitles.
  ///
  /// In en, this message translates to:
  /// **'Failed to load subtitles'**
  String get failedToLoadSubtitles;

  /// No description provided for @pasteYourText.
  ///
  /// In en, this message translates to:
  /// **'Paste your text here...'**
  String get pasteYourText;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Professional Teleprompter'**
  String get welcomeMessage;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Load a file, enter your text, or import YouTube subtitles to get started'**
  String get welcomeSubtitle;

  /// No description provided for @homeHeadline.
  ///
  /// In en, this message translates to:
  /// **'OverScript Studio'**
  String get homeHeadline;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Quick imports: files or PDF'**
  String get homeSubtitle;

  /// No description provided for @footerCopyright.
  ///
  /// In en, this message translates to:
  /// **'© {year} OverLimits Digital Enterprise'**
  String footerCopyright(Object year);

  /// No description provided for @footerBy.
  ///
  /// In en, this message translates to:
  /// **'Built by Jacobin Fokou for OverLimits Digital Enterprise'**
  String get footerBy;

  /// No description provided for @footerLinkedin.
  ///
  /// In en, this message translates to:
  /// **'LinkedIn'**
  String get footerLinkedin;

  /// No description provided for @footerLinkedinUrl.
  ///
  /// In en, this message translates to:
  /// **'linkedin.com/in/jacobindanielfokou'**
  String get footerLinkedinUrl;

  /// No description provided for @legalCgu.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get legalCgu;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @behavior.
  ///
  /// In en, this message translates to:
  /// **'Behavior'**
  String get behavior;

  /// No description provided for @toolbox.
  ///
  /// In en, this message translates to:
  /// **'Toolbar'**
  String get toolbox;

  /// No description provided for @advanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @fontFamily.
  ///
  /// In en, this message translates to:
  /// **'Font'**
  String get fontFamily;

  /// No description provided for @bold.
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get bold;

  /// No description provided for @italic.
  ///
  /// In en, this message translates to:
  /// **'Italic'**
  String get italic;

  /// No description provided for @underline.
  ///
  /// In en, this message translates to:
  /// **'Underline'**
  String get underline;

  /// No description provided for @textEditor.
  ///
  /// In en, this message translates to:
  /// **'Text Editor'**
  String get textEditor;

  /// No description provided for @richTextMode.
  ///
  /// In en, this message translates to:
  /// **'Rich Text Mode'**
  String get richTextMode;

  /// No description provided for @plainTextMode.
  ///
  /// In en, this message translates to:
  /// **'Plain Text Mode'**
  String get plainTextMode;

  /// No description provided for @youtubeSubtitles.
  ///
  /// In en, this message translates to:
  /// **'YouTube Subtitles'**
  String get youtubeSubtitles;

  /// No description provided for @noVideoIdFound.
  ///
  /// In en, this message translates to:
  /// **'No video ID found in URL'**
  String get noVideoIdFound;

  /// No description provided for @invalidUrl.
  ///
  /// In en, this message translates to:
  /// **'Invalid URL'**
  String get invalidUrl;

  /// No description provided for @fetchingSubtitles.
  ///
  /// In en, this message translates to:
  /// **'Fetching subtitles...'**
  String get fetchingSubtitles;

  /// No description provided for @vertical.
  ///
  /// In en, this message translates to:
  /// **'Vertical'**
  String get vertical;

  /// No description provided for @horizontal.
  ///
  /// In en, this message translates to:
  /// **'Horizontal'**
  String get horizontal;

  /// No description provided for @toolboxOrientation.
  ///
  /// In en, this message translates to:
  /// **'Toolbar Orientation'**
  String get toolboxOrientation;

  /// No description provided for @toggleOrientation.
  ///
  /// In en, this message translates to:
  /// **'Toggle orientation'**
  String get toggleOrientation;

  /// No description provided for @playback.
  ///
  /// In en, this message translates to:
  /// **'Playback'**
  String get playback;

  /// No description provided for @speedUnit.
  ///
  /// In en, this message translates to:
  /// **'Speed unit'**
  String get speedUnit;

  /// No description provided for @speedUnitPixels.
  ///
  /// In en, this message translates to:
  /// **'Pixels per second'**
  String get speedUnitPixels;

  /// No description provided for @speedUnitLines.
  ///
  /// In en, this message translates to:
  /// **'Lines per minute'**
  String get speedUnitLines;

  /// No description provided for @speedUnitWords.
  ///
  /// In en, this message translates to:
  /// **'Words per minute'**
  String get speedUnitWords;

  /// No description provided for @defaultSpeed.
  ///
  /// In en, this message translates to:
  /// **'Default speed'**
  String get defaultSpeed;

  /// No description provided for @countdownSeconds.
  ///
  /// In en, this message translates to:
  /// **'Countdown (seconds)'**
  String get countdownSeconds;

  /// No description provided for @autoFullscreenOnStart.
  ///
  /// In en, this message translates to:
  /// **'Auto fullscreen on start'**
  String get autoFullscreenOnStart;

  /// No description provided for @autoFullscreenDescription.
  ///
  /// In en, this message translates to:
  /// **'Switch to fullscreen automatically when starting the prompter'**
  String get autoFullscreenDescription;

  /// No description provided for @trialActiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Test period'**
  String get trialActiveTitle;

  /// No description provided for @trialActiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Remaining: {days} days'**
  String trialActiveLabel(Object days);

  /// No description provided for @trialExpiresOn.
  ///
  /// In en, this message translates to:
  /// **'Expires on {date}'**
  String trialExpiresOn(Object date);

  /// No description provided for @trialExpiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Trial expired'**
  String get trialExpiredTitle;

  /// No description provided for @trialExpiredMessage.
  ///
  /// In en, this message translates to:
  /// **'The testing period has ended. Source selection is disabled.'**
  String get trialExpiredMessage;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @cameraRecording.
  ///
  /// In en, this message translates to:
  /// **'Camera & recording'**
  String get cameraRecording;

  /// No description provided for @autoStartCamera.
  ///
  /// In en, this message translates to:
  /// **'Start camera automatically'**
  String get autoStartCamera;

  /// No description provided for @autoStartCameraDescription.
  ///
  /// In en, this message translates to:
  /// **'Start video capture after countdown'**
  String get autoStartCameraDescription;

  /// No description provided for @cameraAsBackground.
  ///
  /// In en, this message translates to:
  /// **'Camera as background'**
  String get cameraAsBackground;

  /// No description provided for @cameraAsBackgroundDescription.
  ///
  /// In en, this message translates to:
  /// **'Show camera behind text (transparent mode)'**
  String get cameraAsBackgroundDescription;

  /// No description provided for @promptOpacity.
  ///
  /// In en, this message translates to:
  /// **'Prompt opacity'**
  String get promptOpacity;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @microphone.
  ///
  /// In en, this message translates to:
  /// **'Microphone'**
  String get microphone;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get systemDefault;

  /// No description provided for @builtInCamera.
  ///
  /// In en, this message translates to:
  /// **'Built-in camera'**
  String get builtInCamera;

  /// No description provided for @externalCamera.
  ///
  /// In en, this message translates to:
  /// **'External camera'**
  String get externalCamera;

  /// No description provided for @builtInMic.
  ///
  /// In en, this message translates to:
  /// **'Built-in mic'**
  String get builtInMic;

  /// No description provided for @externalMic.
  ///
  /// In en, this message translates to:
  /// **'External mic'**
  String get externalMic;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @helpPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpPageTitle;

  /// No description provided for @infoOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'System overview'**
  String get infoOverviewTitle;

  /// No description provided for @infoOverviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Environment, storage, and license details at a glance.'**
  String get infoOverviewSubtitle;

  /// No description provided for @infoOs.
  ///
  /// In en, this message translates to:
  /// **'OS'**
  String get infoOs;

  /// No description provided for @infoOsVersion.
  ///
  /// In en, this message translates to:
  /// **'OS version'**
  String get infoOsVersion;

  /// No description provided for @infoArchitecture.
  ///
  /// In en, this message translates to:
  /// **'Architecture'**
  String get infoArchitecture;

  /// No description provided for @infoResolution.
  ///
  /// In en, this message translates to:
  /// **'Resolution'**
  String get infoResolution;

  /// No description provided for @infoLocale.
  ///
  /// In en, this message translates to:
  /// **'Locale'**
  String get infoLocale;

  /// No description provided for @infoRecordingsFolder.
  ///
  /// In en, this message translates to:
  /// **'Recordings folder'**
  String get infoRecordingsFolder;

  /// No description provided for @infoOpenRecordingsFolder.
  ///
  /// In en, this message translates to:
  /// **'Open recordings folder'**
  String get infoOpenRecordingsFolder;

  /// No description provided for @infoVideosCount.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get infoVideosCount;

  /// No description provided for @infoTrial.
  ///
  /// In en, this message translates to:
  /// **'Trial'**
  String get infoTrial;

  /// No description provided for @infoMac.
  ///
  /// In en, this message translates to:
  /// **'MAC'**
  String get infoMac;

  /// No description provided for @videosEmpty.
  ///
  /// In en, this message translates to:
  /// **'No recordings found yet'**
  String get videosEmpty;

  /// No description provided for @videosTab.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get videosTab;

  /// No description provided for @helpWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to OverScript Studio'**
  String get helpWelcomeTitle;

  /// No description provided for @helpWelcomeDescription.
  ///
  /// In en, this message translates to:
  /// **'OverScript Studio is a professional teleprompter designed for content creators, speakers, and video producers. This guide will help you get started.'**
  String get helpWelcomeDescription;

  /// No description provided for @helpGettingStarted.
  ///
  /// In en, this message translates to:
  /// **'Getting Started'**
  String get helpGettingStarted;

  /// No description provided for @helpStep1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Add Your Content'**
  String get helpStep1Title;

  /// No description provided for @helpStep1Description.
  ///
  /// In en, this message translates to:
  /// **'Import a file (TXT, PDF, SRT, YouTube) or paste your text directly to prepare the prompter.'**
  String get helpStep1Description;

  /// No description provided for @helpStep1Cta.
  ///
  /// In en, this message translates to:
  /// **'Add sources'**
  String get helpStep1Cta;

  /// No description provided for @helpStep2Title.
  ///
  /// In en, this message translates to:
  /// **'2. Customize Settings'**
  String get helpStep2Title;

  /// No description provided for @helpStep2Description.
  ///
  /// In en, this message translates to:
  /// **'Adjust font size, speed, colors, mirror mode, and layout in the settings menu.'**
  String get helpStep2Description;

  /// No description provided for @helpStep2Cta.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get helpStep2Cta;

  /// No description provided for @helpStep3Title.
  ///
  /// In en, this message translates to:
  /// **'3. Start Recording'**
  String get helpStep3Title;

  /// No description provided for @helpStep3Description.
  ///
  /// In en, this message translates to:
  /// **'Press the play button to start the teleprompter and begin recording when you are ready.'**
  String get helpStep3Description;

  /// No description provided for @helpFeaturesTitle.
  ///
  /// In en, this message translates to:
  /// **'Key Features'**
  String get helpFeaturesTitle;

  /// No description provided for @helpFeature1.
  ///
  /// In en, this message translates to:
  /// **'System overview tab with locale-aware details and recording folder shortcut'**
  String get helpFeature1;

  /// No description provided for @helpFeature2.
  ///
  /// In en, this message translates to:
  /// **'Per-video actions: open in folder, share, or delete recordings'**
  String get helpFeature2;

  /// No description provided for @helpFeature3.
  ///
  /// In en, this message translates to:
  /// **'Customizable speed, fonts, colors, and mirror mode toggle'**
  String get helpFeature3;

  /// No description provided for @helpFeature4.
  ///
  /// In en, this message translates to:
  /// **'Mobile-friendly experience'**
  String get helpFeature4;

  /// No description provided for @helpFeature5.
  ///
  /// In en, this message translates to:
  /// **'Focus mode and fullscreen controls for distraction-free reading'**
  String get helpFeature5;

  /// No description provided for @helpSystemRequirementsTitle.
  ///
  /// In en, this message translates to:
  /// **'System Requirements (Windows)'**
  String get helpSystemRequirementsTitle;

  /// No description provided for @helpSystemRequirementsDescription.
  ///
  /// In en, this message translates to:
  /// **'For Windows users, video recording requires Visual C++ Redistributable 2013 (x64). If you experience issues with recording:'**
  String get helpSystemRequirementsDescription;

  /// No description provided for @helpDownloadVCRedist.
  ///
  /// In en, this message translates to:
  /// **'Download VC++ Redistributable 2013 x64'**
  String get helpDownloadVCRedist;

  /// No description provided for @helpTroubleshootingTitle.
  ///
  /// In en, this message translates to:
  /// **'Troubleshooting'**
  String get helpTroubleshootingTitle;

  /// No description provided for @helpTroubleshoot1Title.
  ///
  /// In en, this message translates to:
  /// **'Camera not working?'**
  String get helpTroubleshoot1Title;

  /// No description provided for @helpTroubleshoot1Description.
  ///
  /// In en, this message translates to:
  /// **'Check that camera permissions are enabled and no other app is using the camera.'**
  String get helpTroubleshoot1Description;

  /// No description provided for @helpTroubleshoot2Title.
  ///
  /// In en, this message translates to:
  /// **'Recording not starting?'**
  String get helpTroubleshoot2Title;

  /// No description provided for @helpTroubleshoot2Description.
  ///
  /// In en, this message translates to:
  /// **'On Windows, install VC++ Redistributable 2013 x64 (link above).'**
  String get helpTroubleshoot2Description;

  /// No description provided for @helpTroubleshoot3Title.
  ///
  /// In en, this message translates to:
  /// **'Text not loading?'**
  String get helpTroubleshoot3Title;

  /// No description provided for @helpTroubleshoot3Description.
  ///
  /// In en, this message translates to:
  /// **'Ensure your file is in a supported format (TXT, VTT, SRT, PDF).'**
  String get helpTroubleshoot3Description;

  /// No description provided for @helpSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Support & Contact'**
  String get helpSupportTitle;

  /// No description provided for @helpSupportDescription.
  ///
  /// In en, this message translates to:
  /// **'For additional help or to report issues, contact us at:'**
  String get helpSupportDescription;

  /// No description provided for @helpSupportEmail.
  ///
  /// In en, this message translates to:
  /// **'danieluokof@gmail.com'**
  String get helpSupportEmail;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
