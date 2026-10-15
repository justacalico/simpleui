// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Irish (`ga`).
class AppLocalizationsGa extends AppLocalizations {
  AppLocalizationsGa([String locale = 'ga']) : super(locale);

  @override
  String get appTitle => 'SimpleUI';

  @override
  String get navGenerate => 'Gin';

  @override
  String get navGallery => 'Gailearaí';

  @override
  String get navQueue => 'Scuaine';

  @override
  String get navWorkflows => 'Sreabhadh oibre';

  @override
  String get navSettings => 'Socruithe';

  @override
  String get navMore => 'Tuilleadh';

  @override
  String get expandSidebar => 'Leathnaigh an bharra taobh';

  @override
  String get collapseSidebar => 'Laghdaigh an bharra taobh';

  @override
  String get generateHeadline => 'Cad is mian leat a chruthú?';

  @override
  String get promptHint => 'Déan cur síos ar an íomhá atá uait…';

  @override
  String get advancedOptions => 'Ardroghanna';

  @override
  String get generate => 'Gin';

  @override
  String get negativePrompt => 'Leid dhiúltach';

  @override
  String get model => 'Samhail';

  @override
  String get sampler => 'Samplálaí';

  @override
  String get scheduler => 'Sceidealaitheoir';

  @override
  String get steps => 'Céimeanna';

  @override
  String get cfg => 'CFG';

  @override
  String get seed => 'Síol';

  @override
  String get randomSeed => 'Síol randamach';

  @override
  String get keepSeed => 'Coinnigh an síol';

  @override
  String batchCount(int count) {
    return 'Baisc: $count';
  }

  @override
  String get jobQueued => 'Sa scuaine';

  @override
  String jobRunning(String progress) {
    return 'Á ghiniúint… $progress%';
  }

  @override
  String get jobDone => 'Déanta';

  @override
  String get jobFailed => 'Theip';

  @override
  String get jobInterrupted => 'Curtha isteach';

  @override
  String get emptyResults =>
      'Tada anseo go fóil. Déan cur síos ar íomhá agus brúigh Gin.';

  @override
  String get latestResult => 'An toradh is déanaí';

  @override
  String get galleryEmpty => 'Gan aon ghiniúint go fóil';

  @override
  String queueSummary(int running, int pending) {
    return '$running á rith · $pending sa scuaine';
  }

  @override
  String get refresh => 'Athnuaigh';

  @override
  String get interrupt => 'Cuir isteach';

  @override
  String get clearQueue => 'Glan an scuaine';

  @override
  String get queueEmpty => 'Tá an scuaine folamh';

  @override
  String get untitledJob => '(gan leid)';

  @override
  String imageCount(int count) {
    return '$count íomhá';
  }

  @override
  String get workflowsIntro =>
      'Roghnaigh an sreabhadh oibre ComfyUI a thiomáineann an ghiniúint. Iompórtáil JSON sreabhadh oibre API chun an graf a shaincheapadh.';

  @override
  String get importWorkflow => 'Iompórtáil sreabhadh oibre';

  @override
  String get workflowName => 'Ainm';

  @override
  String get workflowJson => 'JSON sreabhadh oibre (formáid API)';

  @override
  String get loadFromFile => 'Luchtaigh ó chomhad';

  @override
  String get cancel => 'Cealaigh';

  @override
  String get importAction => 'Iompórtáil';

  @override
  String get invalidWorkflow => 'Ní cosúil gur sreabhadh oibre API é sin';

  @override
  String get workflowImported => 'Sreabhadh oibre iompórtáilte';

  @override
  String get builtinWorkflowName => 'Téacs go híomhá';

  @override
  String get builtinWorkflowDesc =>
      'txt2img ionsuite: checkpoint, leideanna, samplálaí agus méid';

  @override
  String nodeCount(int count) {
    return '$count nód';
  }

  @override
  String get serverSection => 'Freastalaí ComfyUI';

  @override
  String get serverUrl => 'URL an fhreastalaí';

  @override
  String get invalidServerUrl => 'Cuir isteach URL http(s) bailí';

  @override
  String get testConnection => 'Tástáil an nasc';

  @override
  String serverOk(String version, String device) {
    return 'Ceangailte · $version ar $device';
  }

  @override
  String get serverFailed =>
      'Níorbh fhéidir teagmháil a dhéanamh leis an bhfreastalaí';

  @override
  String get serverHint => 'Pointigh é seo ag instans ComfyUI atá ag rith';

  @override
  String get appearanceSection => 'Cuma';

  @override
  String get theme => 'Téama';

  @override
  String get themeSystem => 'Córas';

  @override
  String get themeLight => 'Solas';

  @override
  String get themeDark => 'Dorcha';

  @override
  String get themeOled => 'OLED';

  @override
  String get accentColor => 'Dath béime';

  @override
  String get language => 'Teanga';

  @override
  String get languageSystem => 'Córas';

  @override
  String get aboutSection => 'Maidir leis';

  @override
  String versionLabel(String version) {
    return 'Leagan $version';
  }

  @override
  String get checkUpdates => 'Seiceáil le haghaidh nuashonruithe';

  @override
  String get updateChecking => 'Á sheiceáil…';

  @override
  String get updateFailed => 'Theip ar sheiceáil nuashonruithe';

  @override
  String updateAvailable(String version) {
    return 'Tá leagan $version ar fáil';
  }

  @override
  String get upToDate => 'Nuashonraithe';

  @override
  String getUpdate(String version) {
    return 'Faigh $version';
  }

  @override
  String get releasesLink => 'Gach eisiúint';

  @override
  String get sourceLink => 'Cód foinseach';

  @override
  String get saveImage => 'Sábháil an íomhá';

  @override
  String get delete => 'Scrios';

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
    return 'Samhail $model · síol $seed · $steps céim · CFG $cfg · $sampler/$scheduler · $size';
  }
}
