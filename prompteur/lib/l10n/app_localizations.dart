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
  /// **'Teleprompter'**
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

  /// No description provided for @playback.
  ///
  /// In en, this message translates to:
  /// **'Playback'**
  String get playback;

  /// No description provided for @speedUnit.
  ///
  /// In en, this message translates to:
  /// **'Speed Unit'**
  String get speedUnit;

  /// No description provided for @pixelsPerSecond.
  ///
  /// In en, this message translates to:
  /// **'Pixels per second'**
  String get pixelsPerSecond;

  /// No description provided for @linesPerMinute.
  ///
  /// In en, this message translates to:
  /// **'Lines per minute'**
  String get linesPerMinute;

  /// No description provided for @wordsPerMinute.
  ///
  /// In en, this message translates to:
  /// **'Words per minute'**
  String get wordsPerMinute;

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
  /// **'The app will go fullscreen when you start the prompter'**
  String get autoFullscreenDescription;

  /// No description provided for @backgroundColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Background color'**
  String get backgroundColorLabel;

  /// No description provided for @textColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Text color'**
  String get textColorLabel;

  /// No description provided for @fontSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Font size'**
  String get fontSizeLabel;

  /// No description provided for @toolbarPosition.
  ///
  /// In en, this message translates to:
  /// **'Toolbar position'**
  String get toolbarPosition;

  /// No description provided for @toolbarPositionTop.
  ///
  /// In en, this message translates to:
  /// **'Top'**
  String get toolbarPositionTop;

  /// No description provided for @toolbarPositionTopCenter.
  ///
  /// In en, this message translates to:
  /// **'Top (center)'**
  String get toolbarPositionTopCenter;

  /// No description provided for @toolbarPositionBottom.
  ///
  /// In en, this message translates to:
  /// **'Bottom'**
  String get toolbarPositionBottom;

  /// No description provided for @toolbarPositionBottomCenter.
  ///
  /// In en, this message translates to:
  /// **'Bottom (center)'**
  String get toolbarPositionBottomCenter;

  /// No description provided for @toolbarPositionLeft.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get toolbarPositionLeft;

  /// No description provided for @toolbarPositionRight.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get toolbarPositionRight;

  /// No description provided for @toolbarPositionTopLeft.
  ///
  /// In en, this message translates to:
  /// **'Top left corner'**
  String get toolbarPositionTopLeft;

  /// No description provided for @toolbarPositionTopRight.
  ///
  /// In en, this message translates to:
  /// **'Top right corner'**
  String get toolbarPositionTopRight;

  /// No description provided for @toolbarPositionBottomLeft.
  ///
  /// In en, this message translates to:
  /// **'Bottom left corner'**
  String get toolbarPositionBottomLeft;

  /// No description provided for @toolbarPositionBottomRight.
  ///
  /// In en, this message translates to:
  /// **'Bottom right corner'**
  String get toolbarPositionBottomRight;

  /// No description provided for @toolboxOrientationLabel.
  ///
  /// In en, this message translates to:
  /// **'Toolbox orientation'**
  String get toolboxOrientationLabel;

  /// No description provided for @toolboxOrientationAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto (by position)'**
  String get toolboxOrientationAuto;

  /// No description provided for @toolboxSize.
  ///
  /// In en, this message translates to:
  /// **'Toolbox size'**
  String get toolboxSize;

  /// No description provided for @toolboxThemeLabel.
  ///
  /// In en, this message translates to:
  /// **'Toolbox theme'**
  String get toolboxThemeLabel;

  /// No description provided for @toolboxThemeModern.
  ///
  /// In en, this message translates to:
  /// **'Modern'**
  String get toolboxThemeModern;

  /// No description provided for @toolboxThemeGlass.
  ///
  /// In en, this message translates to:
  /// **'Glass'**
  String get toolboxThemeGlass;

  /// No description provided for @toolboxThemeContrast.
  ///
  /// In en, this message translates to:
  /// **'High contrast'**
  String get toolboxThemeContrast;

  /// No description provided for @showTimerAndClock.
  ///
  /// In en, this message translates to:
  /// **'Show timer and clock'**
  String get showTimerAndClock;

  /// No description provided for @showTimerDescription.
  ///
  /// In en, this message translates to:
  /// **'Display timer and clock in the toolbox'**
  String get showTimerDescription;

  /// No description provided for @controls.
  ///
  /// In en, this message translates to:
  /// **'Controls'**
  String get controls;

  /// No description provided for @pauseOnMouseMove.
  ///
  /// In en, this message translates to:
  /// **'Pause on mouse move'**
  String get pauseOnMouseMove;

  /// No description provided for @pauseOnMouseMoveDescription.
  ///
  /// In en, this message translates to:
  /// **'Scrolling pauses when you move the mouse'**
  String get pauseOnMouseMoveDescription;

  /// No description provided for @blockNotificationsFocusMode.
  ///
  /// In en, this message translates to:
  /// **'Block notifications (Focus mode)'**
  String get blockNotificationsFocusMode;

  /// No description provided for @blockNotificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Enable Do Not Disturb while the prompter runs'**
  String get blockNotificationsDescription;

  /// No description provided for @keyboardShortcuts.
  ///
  /// In en, this message translates to:
  /// **'Keyboard shortcuts'**
  String get keyboardShortcuts;

  /// No description provided for @playPause.
  ///
  /// In en, this message translates to:
  /// **'Play / Pause'**
  String get playPause;

  /// No description provided for @toggleFullscreen.
  ///
  /// In en, this message translates to:
  /// **'Toggle fullscreen'**
  String get toggleFullscreen;

  /// No description provided for @exitFullscreenShortcut.
  ///
  /// In en, this message translates to:
  /// **'Exit fullscreen'**
  String get exitFullscreenShortcut;

  /// No description provided for @increaseSpeed.
  ///
  /// In en, this message translates to:
  /// **'Increase speed'**
  String get increaseSpeed;

  /// No description provided for @decreaseSpeed.
  ///
  /// In en, this message translates to:
  /// **'Decrease speed'**
  String get decreaseSpeed;
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
