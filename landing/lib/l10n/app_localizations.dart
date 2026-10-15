import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ga.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of LandingLocalizations
/// returned by `LandingLocalizations.of(context)`.
///
/// Applications need to include `LandingLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: LandingLocalizations.localizationsDelegates,
///   supportedLocales: LandingLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the LandingLocalizations.supportedLocales
/// property.
abstract class LandingLocalizations {
  LandingLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static LandingLocalizations of(BuildContext context) {
    return Localizations.of<LandingLocalizations>(
      context,
      LandingLocalizations,
    )!;
  }

  static const LocalizationsDelegate<LandingLocalizations> delegate =
      _LandingLocalizationsDelegate();

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
    Locale('en', 'GB'),
    Locale('ga'),
    Locale('ru'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
  ];

  /// No description provided for @tagline.
  ///
  /// In en_GB, this message translates to:
  /// **'A simple ComfyUI client'**
  String get tagline;

  /// No description provided for @hero.
  ///
  /// In en_GB, this message translates to:
  /// **'Describe it. Get an image.'**
  String get hero;

  /// No description provided for @sub.
  ///
  /// In en_GB, this message translates to:
  /// **'SimpleUI turns a running ComfyUI server into a one-box image generator, like typing into Gemini.'**
  String get sub;

  /// No description provided for @openApp.
  ///
  /// In en_GB, this message translates to:
  /// **'Open the app'**
  String get openApp;

  /// No description provided for @getDownloads.
  ///
  /// In en_GB, this message translates to:
  /// **'Download'**
  String get getDownloads;

  /// No description provided for @featuresTitle.
  ///
  /// In en_GB, this message translates to:
  /// **'Why SimpleUI'**
  String get featuresTitle;

  /// No description provided for @feature1Title.
  ///
  /// In en_GB, this message translates to:
  /// **'One prompt box'**
  String get feature1Title;

  /// No description provided for @feature1Body.
  ///
  /// In en_GB, this message translates to:
  /// **'Type what you want and press Generate. No node graphs, no wiring, no fuss.'**
  String get feature1Body;

  /// No description provided for @feature2Title.
  ///
  /// In en_GB, this message translates to:
  /// **'Every platform'**
  String get feature2Title;

  /// No description provided for @feature2Body.
  ///
  /// In en_GB, this message translates to:
  /// **'Linux, macOS, Windows, Android, iOS and the web, all from one build.'**
  String get feature2Body;

  /// No description provided for @feature3Title.
  ///
  /// In en_GB, this message translates to:
  /// **'Your server, your rules'**
  String get feature3Title;

  /// No description provided for @feature3Body.
  ///
  /// In en_GB, this message translates to:
  /// **'Point it at any ComfyUI instance. Custom workflows, samplers and seeds under the hood.'**
  String get feature3Body;

  /// No description provided for @downloadsTitle.
  ///
  /// In en_GB, this message translates to:
  /// **'Downloads'**
  String get downloadsTitle;

  /// No description provided for @downloadsSub.
  ///
  /// In en_GB, this message translates to:
  /// **'Latest builds straight from the releases feed.'**
  String get downloadsSub;

  /// No description provided for @loadingReleases.
  ///
  /// In en_GB, this message translates to:
  /// **'Loading releases…'**
  String get loadingReleases;

  /// No description provided for @noReleases.
  ///
  /// In en_GB, this message translates to:
  /// **'No releases yet. Check back soon.'**
  String get noReleases;

  /// No description provided for @releasesError.
  ///
  /// In en_GB, this message translates to:
  /// **'Could not load releases.'**
  String get releasesError;

  /// No description provided for @gitlabReleases.
  ///
  /// In en_GB, this message translates to:
  /// **'GitLab releases'**
  String get gitlabReleases;

  /// No description provided for @flatpakHint.
  ///
  /// In en_GB, this message translates to:
  /// **'Linux one-liner:'**
  String get flatpakHint;

  /// No description provided for @sourceLink.
  ///
  /// In en_GB, this message translates to:
  /// **'Source on GitLab'**
  String get sourceLink;

  /// No description provided for @theme.
  ///
  /// In en_GB, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en_GB, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en_GB, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en_GB, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeOled.
  ///
  /// In en_GB, this message translates to:
  /// **'OLED'**
  String get themeOled;

  /// No description provided for @language.
  ///
  /// In en_GB, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en_GB, this message translates to:
  /// **'System'**
  String get languageSystem;
}

class _LandingLocalizationsDelegate
    extends LocalizationsDelegate<LandingLocalizations> {
  const _LandingLocalizationsDelegate();

  @override
  Future<LandingLocalizations> load(Locale locale) {
    return SynchronousFuture<LandingLocalizations>(
      lookupLandingLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ga', 'ru', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_LandingLocalizationsDelegate old) => false;
}

LandingLocalizations lookupLandingLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hans':
            return LandingLocalizationsZhHans();
        }
        break;
      }
  }

  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'en':
      {
        switch (locale.countryCode) {
          case 'GB':
            return LandingLocalizationsEnGb();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return LandingLocalizationsEn();
    case 'ga':
      return LandingLocalizationsGa();
    case 'ru':
      return LandingLocalizationsRu();
    case 'zh':
      return LandingLocalizationsZh();
  }

  throw FlutterError(
    'LandingLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
