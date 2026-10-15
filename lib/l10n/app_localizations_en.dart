// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SimpleUI';

  @override
  String get navGenerate => 'Generate';

  @override
  String get navGallery => 'Gallery';

  @override
  String get navQueue => 'Queue';

  @override
  String get navWorkflows => 'Workflows';

  @override
  String get navSettings => 'Settings';

  @override
  String get navMore => 'More';

  @override
  String get expandSidebar => 'Expand sidebar';

  @override
  String get collapseSidebar => 'Collapse sidebar';

  @override
  String get generateHeadline => 'What do you want to create?';

  @override
  String get promptHint => 'Describe the image you want…';

  @override
  String get advancedOptions => 'Advanced options';

  @override
  String get generate => 'Generate';

  @override
  String get negativePrompt => 'Negative prompt';

  @override
  String get model => 'Model';

  @override
  String get sampler => 'Sampler';

  @override
  String get scheduler => 'Scheduler';

  @override
  String get steps => 'Steps';

  @override
  String get cfg => 'CFG';

  @override
  String get seed => 'Seed';

  @override
  String get randomSeed => 'Random seed';

  @override
  String get keepSeed => 'Keep seed';

  @override
  String batchCount(int count) {
    return 'Batch: $count';
  }

  @override
  String get jobQueued => 'Queued';

  @override
  String jobRunning(String progress) {
    return 'Generating… $progress%';
  }

  @override
  String get jobDone => 'Done';

  @override
  String get jobFailed => 'Failed';

  @override
  String get jobInterrupted => 'Interrupted';

  @override
  String get emptyResults =>
      'Nothing here yet. Describe an image and press Generate.';

  @override
  String get latestResult => 'Latest result';

  @override
  String get galleryEmpty => 'No generations yet';

  @override
  String queueSummary(int running, int pending) {
    return '$running running · $pending queued';
  }

  @override
  String get refresh => 'Refresh';

  @override
  String get interrupt => 'Interrupt';

  @override
  String get clearQueue => 'Clear queue';

  @override
  String get queueEmpty => 'The queue is empty';

  @override
  String get untitledJob => '(no prompt)';

  @override
  String imageCount(int count) {
    return '$count image(s)';
  }

  @override
  String get workflowsIntro =>
      'Pick which ComfyUI workflow drives generation. Import an API-format workflow JSON to customise the graph.';

  @override
  String get importWorkflow => 'Import workflow';

  @override
  String get workflowName => 'Name';

  @override
  String get workflowJson => 'Workflow JSON (API format)';

  @override
  String get loadFromFile => 'Load from file';

  @override
  String get cancel => 'Cancel';

  @override
  String get importAction => 'Import';

  @override
  String get invalidWorkflow =>
      'That does not look like an API-format workflow';

  @override
  String get workflowImported => 'Workflow imported';

  @override
  String get builtinWorkflowName => 'Text to image';

  @override
  String get builtinWorkflowDesc =>
      'Built-in txt2img: checkpoint, prompts, sampler and latent size';

  @override
  String nodeCount(int count) {
    return '$count nodes';
  }

  @override
  String get serverSection => 'ComfyUI server';

  @override
  String get serverUrl => 'Server URL';

  @override
  String get invalidServerUrl => 'Enter a valid http(s) URL';

  @override
  String get testConnection => 'Test connection';

  @override
  String serverOk(String version, String device) {
    return 'Connected · $version on $device';
  }

  @override
  String get serverFailed => 'Could not reach the server';

  @override
  String get serverHint => 'Point this at a running ComfyUI instance';

  @override
  String get appearanceSection => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeOled => 'OLED';

  @override
  String get accentColor => 'Accent colour';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get aboutSection => 'About';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get checkUpdates => 'Check for updates';

  @override
  String get updateChecking => 'Checking…';

  @override
  String get updateFailed => 'Update check failed';

  @override
  String updateAvailable(String version) {
    return 'Version $version is available';
  }

  @override
  String get upToDate => 'Up to date';

  @override
  String getUpdate(String version) {
    return 'Get $version';
  }

  @override
  String get releasesLink => 'All releases';

  @override
  String get sourceLink => 'Source code';

  @override
  String get saveImage => 'Save image';

  @override
  String get delete => 'Delete';

  @override
  String detailMeta(
    String model,
    int seed,
    int steps,
    double cfg,
    String sampler,
    String scheduler,
    String size,
  ) {
    return 'Model $model · seed $seed · $steps steps · CFG $cfg · $sampler/$scheduler · $size';
  }
}

/// The translations for English, as used in the United Kingdom (`en_GB`).
class AppLocalizationsEnGb extends AppLocalizationsEn {
  AppLocalizationsEnGb() : super('en_GB');

  @override
  String get appTitle => 'SimpleUI';

  @override
  String get navGenerate => 'Generate';

  @override
  String get navGallery => 'Gallery';

  @override
  String get navQueue => 'Queue';

  @override
  String get navWorkflows => 'Workflows';

  @override
  String get navSettings => 'Settings';

  @override
  String get navMore => 'More';

  @override
  String get expandSidebar => 'Expand sidebar';

  @override
  String get collapseSidebar => 'Collapse sidebar';

  @override
  String get generateHeadline => 'What do you want to create?';

  @override
  String get promptHint => 'Describe the image you want…';

  @override
  String get advancedOptions => 'Advanced options';

  @override
  String get generate => 'Generate';

  @override
  String get negativePrompt => 'Negative prompt';

  @override
  String get model => 'Model';

  @override
  String get sampler => 'Sampler';

  @override
  String get scheduler => 'Scheduler';

  @override
  String get steps => 'Steps';

  @override
  String get cfg => 'CFG';

  @override
  String get seed => 'Seed';

  @override
  String get randomSeed => 'Random seed';

  @override
  String get keepSeed => 'Keep seed';

  @override
  String batchCount(int count) {
    return 'Batch: $count';
  }

  @override
  String get jobQueued => 'Queued';

  @override
  String jobRunning(String progress) {
    return 'Generating… $progress%';
  }

  @override
  String get jobDone => 'Done';

  @override
  String get jobFailed => 'Failed';

  @override
  String get jobInterrupted => 'Interrupted';

  @override
  String get emptyResults =>
      'Nothing here yet. Describe an image and press Generate.';

  @override
  String get latestResult => 'Latest result';

  @override
  String get galleryEmpty => 'No generations yet';

  @override
  String queueSummary(int running, int pending) {
    return '$running running · $pending queued';
  }

  @override
  String get refresh => 'Refresh';

  @override
  String get interrupt => 'Interrupt';

  @override
  String get clearQueue => 'Clear queue';

  @override
  String get queueEmpty => 'The queue is empty';

  @override
  String get untitledJob => '(no prompt)';

  @override
  String imageCount(int count) {
    return '$count image(s)';
  }

  @override
  String get workflowsIntro =>
      'Pick which ComfyUI workflow drives generation. Import an API-format workflow JSON to customise the graph.';

  @override
  String get importWorkflow => 'Import workflow';

  @override
  String get workflowName => 'Name';

  @override
  String get workflowJson => 'Workflow JSON (API format)';

  @override
  String get loadFromFile => 'Load from file';

  @override
  String get cancel => 'Cancel';

  @override
  String get importAction => 'Import';

  @override
  String get invalidWorkflow =>
      'That does not look like an API-format workflow';

  @override
  String get workflowImported => 'Workflow imported';

  @override
  String get builtinWorkflowName => 'Text to image';

  @override
  String get builtinWorkflowDesc =>
      'Built-in txt2img: checkpoint, prompts, sampler and latent size';

  @override
  String nodeCount(int count) {
    return '$count nodes';
  }

  @override
  String get serverSection => 'ComfyUI server';

  @override
  String get serverUrl => 'Server URL';

  @override
  String get invalidServerUrl => 'Enter a valid http(s) URL';

  @override
  String get testConnection => 'Test connection';

  @override
  String serverOk(String version, String device) {
    return 'Connected · $version on $device';
  }

  @override
  String get serverFailed => 'Could not reach the server';

  @override
  String get serverHint => 'Point this at a running ComfyUI instance';

  @override
  String get appearanceSection => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeOled => 'OLED';

  @override
  String get accentColor => 'Accent colour';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get aboutSection => 'About';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get checkUpdates => 'Check for updates';

  @override
  String get updateChecking => 'Checking…';

  @override
  String get updateFailed => 'Update check failed';

  @override
  String updateAvailable(String version) {
    return 'Version $version is available';
  }

  @override
  String get upToDate => 'Up to date';

  @override
  String getUpdate(String version) {
    return 'Get $version';
  }

  @override
  String get releasesLink => 'All releases';

  @override
  String get sourceLink => 'Source code';

  @override
  String get saveImage => 'Save image';

  @override
  String get delete => 'Delete';

  @override
  String detailMeta(
    String model,
    int seed,
    int steps,
    double cfg,
    String sampler,
    String scheduler,
    String size,
  ) {
    return 'Model $model · seed $seed · $steps steps · CFG $cfg · $sampler/$scheduler · $size';
  }
}
