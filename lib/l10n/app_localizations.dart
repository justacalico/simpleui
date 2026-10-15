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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('en', 'GB'),
    Locale('ga'),
    Locale('ru'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en_GB, this message translates to:
  /// **'SimpleUI'**
  String get appTitle;

  /// No description provided for @navGenerate.
  ///
  /// In en_GB, this message translates to:
  /// **'Generate'**
  String get navGenerate;

  /// No description provided for @navGallery.
  ///
  /// In en_GB, this message translates to:
  /// **'Gallery'**
  String get navGallery;

  /// No description provided for @navQueue.
  ///
  /// In en_GB, this message translates to:
  /// **'Queue'**
  String get navQueue;

  /// No description provided for @navWorkflows.
  ///
  /// In en_GB, this message translates to:
  /// **'Workflows'**
  String get navWorkflows;

  /// No description provided for @navSettings.
  ///
  /// In en_GB, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navMore.
  ///
  /// In en_GB, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @expandSidebar.
  ///
  /// In en_GB, this message translates to:
  /// **'Expand sidebar'**
  String get expandSidebar;

  /// No description provided for @collapseSidebar.
  ///
  /// In en_GB, this message translates to:
  /// **'Collapse sidebar'**
  String get collapseSidebar;

  /// No description provided for @generateHeadline.
  ///
  /// In en_GB, this message translates to:
  /// **'What do you want to create?'**
  String get generateHeadline;

  /// No description provided for @promptHint.
  ///
  /// In en_GB, this message translates to:
  /// **'Describe the image you want…'**
  String get promptHint;

  /// No description provided for @advancedOptions.
  ///
  /// In en_GB, this message translates to:
  /// **'Advanced options'**
  String get advancedOptions;

  /// No description provided for @generate.
  ///
  /// In en_GB, this message translates to:
  /// **'Generate'**
  String get generate;

  /// No description provided for @negativePrompt.
  ///
  /// In en_GB, this message translates to:
  /// **'Negative prompt'**
  String get negativePrompt;

  /// No description provided for @model.
  ///
  /// In en_GB, this message translates to:
  /// **'Model'**
  String get model;

  /// No description provided for @sampler.
  ///
  /// In en_GB, this message translates to:
  /// **'Sampler'**
  String get sampler;

  /// No description provided for @scheduler.
  ///
  /// In en_GB, this message translates to:
  /// **'Scheduler'**
  String get scheduler;

  /// No description provided for @steps.
  ///
  /// In en_GB, this message translates to:
  /// **'Steps'**
  String get steps;

  /// No description provided for @cfg.
  ///
  /// In en_GB, this message translates to:
  /// **'CFG'**
  String get cfg;

  /// No description provided for @seed.
  ///
  /// In en_GB, this message translates to:
  /// **'Seed'**
  String get seed;

  /// No description provided for @randomSeed.
  ///
  /// In en_GB, this message translates to:
  /// **'Random seed'**
  String get randomSeed;

  /// No description provided for @keepSeed.
  ///
  /// In en_GB, this message translates to:
  /// **'Keep seed'**
  String get keepSeed;

  /// No description provided for @batchCount.
  ///
  /// In en_GB, this message translates to:
  /// **'Batch: {count}'**
  String batchCount(int count);

  /// No description provided for @jobQueued.
  ///
  /// In en_GB, this message translates to:
  /// **'Queued'**
  String get jobQueued;

  /// No description provided for @jobRunning.
  ///
  /// In en_GB, this message translates to:
  /// **'Generating… {progress}%'**
  String jobRunning(String progress);

  /// No description provided for @jobDone.
  ///
  /// In en_GB, this message translates to:
  /// **'Done'**
  String get jobDone;

  /// No description provided for @jobFailed.
  ///
  /// In en_GB, this message translates to:
  /// **'Failed'**
  String get jobFailed;

  /// No description provided for @jobInterrupted.
  ///
  /// In en_GB, this message translates to:
  /// **'Interrupted'**
  String get jobInterrupted;

  /// No description provided for @emptyResults.
  ///
  /// In en_GB, this message translates to:
  /// **'Nothing here yet. Describe an image and press Generate.'**
  String get emptyResults;

  /// No description provided for @latestResult.
  ///
  /// In en_GB, this message translates to:
  /// **'Latest result'**
  String get latestResult;

  /// No description provided for @galleryEmpty.
  ///
  /// In en_GB, this message translates to:
  /// **'No generations yet'**
  String get galleryEmpty;

  /// No description provided for @queueSummary.
  ///
  /// In en_GB, this message translates to:
  /// **'{running} running · {pending} queued'**
  String queueSummary(int running, int pending);

  /// No description provided for @refresh.
  ///
  /// In en_GB, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @interrupt.
  ///
  /// In en_GB, this message translates to:
  /// **'Interrupt'**
  String get interrupt;

  /// No description provided for @clearQueue.
  ///
  /// In en_GB, this message translates to:
  /// **'Clear queue'**
  String get clearQueue;

  /// No description provided for @queueEmpty.
  ///
  /// In en_GB, this message translates to:
  /// **'The queue is empty'**
  String get queueEmpty;

  /// No description provided for @untitledJob.
  ///
  /// In en_GB, this message translates to:
  /// **'(no prompt)'**
  String get untitledJob;

  /// No description provided for @imageCount.
  ///
  /// In en_GB, this message translates to:
  /// **'{count} image(s)'**
  String imageCount(int count);

  /// No description provided for @workflowsIntro.
  ///
  /// In en_GB, this message translates to:
  /// **'Pick which ComfyUI workflow drives generation. Import an API-format workflow JSON to customise the graph.'**
  String get workflowsIntro;

  /// No description provided for @importWorkflow.
  ///
  /// In en_GB, this message translates to:
  /// **'Import workflow'**
  String get importWorkflow;

  /// No description provided for @workflowName.
  ///
  /// In en_GB, this message translates to:
  /// **'Name'**
  String get workflowName;

  /// No description provided for @workflowJson.
  ///
  /// In en_GB, this message translates to:
  /// **'Workflow JSON (API format)'**
  String get workflowJson;

  /// No description provided for @loadFromFile.
  ///
  /// In en_GB, this message translates to:
  /// **'Load from file'**
  String get loadFromFile;

  /// No description provided for @cancel.
  ///
  /// In en_GB, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @importAction.
  ///
  /// In en_GB, this message translates to:
  /// **'Import'**
  String get importAction;

  /// No description provided for @invalidWorkflow.
  ///
  /// In en_GB, this message translates to:
  /// **'That does not look like an API-format workflow'**
  String get invalidWorkflow;

  /// No description provided for @workflowImported.
  ///
  /// In en_GB, this message translates to:
  /// **'Workflow imported'**
  String get workflowImported;

  /// No description provided for @builtinWorkflowName.
  ///
  /// In en_GB, this message translates to:
  /// **'Text to image'**
  String get builtinWorkflowName;

  /// No description provided for @builtinWorkflowDesc.
  ///
  /// In en_GB, this message translates to:
  /// **'Built-in txt2img: checkpoint, prompts, sampler and latent size'**
  String get builtinWorkflowDesc;

  /// No description provided for @nodeCount.
  ///
  /// In en_GB, this message translates to:
  /// **'{count} nodes'**
  String nodeCount(int count);

  /// No description provided for @serverSection.
  ///
  /// In en_GB, this message translates to:
  /// **'ComfyUI server'**
  String get serverSection;

  /// No description provided for @serverUrl.
  ///
  /// In en_GB, this message translates to:
  /// **'Server URL'**
  String get serverUrl;

  /// No description provided for @invalidServerUrl.
  ///
  /// In en_GB, this message translates to:
  /// **'Enter a valid http(s) URL'**
  String get invalidServerUrl;

  /// No description provided for @testConnection.
  ///
  /// In en_GB, this message translates to:
  /// **'Test connection'**
  String get testConnection;

  /// No description provided for @serverOk.
  ///
  /// In en_GB, this message translates to:
  /// **'Connected · {version} on {device}'**
  String serverOk(String version, String device);

  /// No description provided for @serverFailed.
  ///
  /// In en_GB, this message translates to:
  /// **'Could not reach the server'**
  String get serverFailed;

  /// No description provided for @serverHint.
  ///
  /// In en_GB, this message translates to:
  /// **'Point this at a running ComfyUI instance'**
  String get serverHint;

  /// No description provided for @appearanceSection.
  ///
  /// In en_GB, this message translates to:
  /// **'Appearance'**
  String get appearanceSection;

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

  /// No description provided for @accentColor.
  ///
  /// In en_GB, this message translates to:
  /// **'Accent colour'**
  String get accentColor;

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

  /// No description provided for @aboutSection.
  ///
  /// In en_GB, this message translates to:
  /// **'About'**
  String get aboutSection;

  /// No description provided for @versionLabel.
  ///
  /// In en_GB, this message translates to:
  /// **'Version {version}'**
  String versionLabel(String version);

  /// No description provided for @checkUpdates.
  ///
  /// In en_GB, this message translates to:
  /// **'Check for updates'**
  String get checkUpdates;

  /// No description provided for @updateChecking.
  ///
  /// In en_GB, this message translates to:
  /// **'Checking…'**
  String get updateChecking;

  /// No description provided for @updateFailed.
  ///
  /// In en_GB, this message translates to:
  /// **'Update check failed'**
  String get updateFailed;

  /// No description provided for @updateAvailable.
  ///
  /// In en_GB, this message translates to:
  /// **'Version {version} is available'**
  String updateAvailable(String version);

  /// No description provided for @upToDate.
  ///
  /// In en_GB, this message translates to:
  /// **'Up to date'**
  String get upToDate;

  /// No description provided for @getUpdate.
  ///
  /// In en_GB, this message translates to:
  /// **'Get {version}'**
  String getUpdate(String version);

  /// No description provided for @releasesLink.
  ///
  /// In en_GB, this message translates to:
  /// **'All releases'**
  String get releasesLink;

  /// No description provided for @sourceLink.
  ///
  /// In en_GB, this message translates to:
  /// **'Source code'**
  String get sourceLink;

  /// No description provided for @saveImage.
  ///
  /// In en_GB, this message translates to:
  /// **'Save image'**
  String get saveImage;

  /// No description provided for @delete.
  ///
  /// In en_GB, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @detailMeta.
  ///
  /// In en_GB, this message translates to:
  /// **'Model {model} · seed {seed} · {steps} steps · CFG {cfg} · {sampler}/{scheduler} · {size}'**
  String detailMeta(
    String model,
    int seed,
    int steps,
    double cfg,
    String sampler,
    String scheduler,
    String size,
  );
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
      <String>['en', 'ga', 'ru', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hans':
            return AppLocalizationsZhHans();
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
            return AppLocalizationsEnGb();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ga':
      return AppLocalizationsGa();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
