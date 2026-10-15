// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'SimpleUI';

  @override
  String get navGenerate => '生成';

  @override
  String get navGallery => '画廊';

  @override
  String get navQueue => '队列';

  @override
  String get navWorkflows => '工作流';

  @override
  String get navSettings => '设置';

  @override
  String get navMore => '更多';

  @override
  String get expandSidebar => '展开侧栏';

  @override
  String get collapseSidebar => '收起侧栏';

  @override
  String get generateHeadline => '你想创作什么？';

  @override
  String get promptHint => '描述你想要的图像…';

  @override
  String get advancedOptions => '高级选项';

  @override
  String get generate => '生成';

  @override
  String get negativePrompt => '负面提示词';

  @override
  String get model => '模型';

  @override
  String get sampler => '采样器';

  @override
  String get scheduler => '调度器';

  @override
  String get steps => '步数';

  @override
  String get cfg => 'CFG';

  @override
  String get seed => '种子';

  @override
  String get randomSeed => '随机种子';

  @override
  String get keepSeed => '固定种子';

  @override
  String batchCount(int count) {
    return '批量：$count';
  }

  @override
  String get jobQueued => '排队中';

  @override
  String jobRunning(String progress) {
    return '生成中… $progress%';
  }

  @override
  String get jobDone => '完成';

  @override
  String get jobFailed => '失败';

  @override
  String get jobInterrupted => '已中断';

  @override
  String get emptyResults => '还没有内容。描述一张图像，然后点击生成。';

  @override
  String get latestResult => '最新结果';

  @override
  String get galleryEmpty => '还没有生成记录';

  @override
  String queueSummary(int running, int pending) {
    return '$running 个运行中 · $pending 个排队中';
  }

  @override
  String get refresh => '刷新';

  @override
  String get interrupt => '中断';

  @override
  String get clearQueue => '清空队列';

  @override
  String get queueEmpty => '队列为空';

  @override
  String get untitledJob => '（无提示词）';

  @override
  String imageCount(int count) {
    return '$count 张图像';
  }

  @override
  String get workflowsIntro => '选择用于生成的 ComfyUI 工作流。导入 API 格式的工作流 JSON 以自定义图。';

  @override
  String get importWorkflow => '导入工作流';

  @override
  String get workflowName => '名称';

  @override
  String get workflowJson => '工作流 JSON（API 格式）';

  @override
  String get loadFromFile => '从文件加载';

  @override
  String get cancel => '取消';

  @override
  String get importAction => '导入';

  @override
  String get invalidWorkflow => '这不是有效的 API 格式工作流';

  @override
  String get workflowImported => '工作流已导入';

  @override
  String get builtinWorkflowName => '文生图';

  @override
  String get builtinWorkflowDesc => '内置 txt2img：checkpoint、提示词、采样器和尺寸';

  @override
  String nodeCount(int count) {
    return '$count 个节点';
  }

  @override
  String get serverSection => 'ComfyUI 服务器';

  @override
  String get serverUrl => '服务器地址';

  @override
  String get invalidServerUrl => '请输入有效的 http(s) 地址';

  @override
  String get testConnection => '测试连接';

  @override
  String serverOk(String version, String device) {
    return '已连接 · $version，设备 $device';
  }

  @override
  String get serverFailed => '无法连接服务器';

  @override
  String get serverHint => '指向一个正在运行的 ComfyUI 实例';

  @override
  String get appearanceSection => '外观';

  @override
  String get theme => '主题';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get themeOled => 'OLED';

  @override
  String get accentColor => '主题色';

  @override
  String get language => '语言';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get aboutSection => '关于';

  @override
  String versionLabel(String version) {
    return '版本 $version';
  }

  @override
  String get checkUpdates => '检查更新';

  @override
  String get updateChecking => '正在检查…';

  @override
  String get updateFailed => '检查更新失败';

  @override
  String updateAvailable(String version) {
    return '新版本 $version 可用';
  }

  @override
  String get upToDate => '已是最新';

  @override
  String getUpdate(String version) {
    return '获取 $version';
  }

  @override
  String get releasesLink => '所有版本';

  @override
  String get sourceLink => '源代码';

  @override
  String get saveImage => '保存图像';

  @override
  String get delete => '删除';

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
    return '模型 $model · 种子 $seed · $steps 步 · CFG $cfg · $sampler/$scheduler · $size';
  }
}

/// The translations for Chinese, using the Han script (`zh_Hans`).
class AppLocalizationsZhHans extends AppLocalizationsZh {
  AppLocalizationsZhHans() : super('zh_Hans');

  @override
  String get appTitle => 'SimpleUI';

  @override
  String get navGenerate => '生成';

  @override
  String get navGallery => '画廊';

  @override
  String get navQueue => '队列';

  @override
  String get navWorkflows => '工作流';

  @override
  String get navSettings => '设置';

  @override
  String get navMore => '更多';

  @override
  String get expandSidebar => '展开侧栏';

  @override
  String get collapseSidebar => '收起侧栏';

  @override
  String get generateHeadline => '你想创作什么？';

  @override
  String get promptHint => '描述你想要的图像…';

  @override
  String get advancedOptions => '高级选项';

  @override
  String get generate => '生成';

  @override
  String get negativePrompt => '负面提示词';

  @override
  String get model => '模型';

  @override
  String get sampler => '采样器';

  @override
  String get scheduler => '调度器';

  @override
  String get steps => '步数';

  @override
  String get cfg => 'CFG';

  @override
  String get seed => '种子';

  @override
  String get randomSeed => '随机种子';

  @override
  String get keepSeed => '固定种子';

  @override
  String batchCount(int count) {
    return '批量：$count';
  }

  @override
  String get jobQueued => '排队中';

  @override
  String jobRunning(String progress) {
    return '生成中… $progress%';
  }

  @override
  String get jobDone => '完成';

  @override
  String get jobFailed => '失败';

  @override
  String get jobInterrupted => '已中断';

  @override
  String get emptyResults => '还没有内容。描述一张图像，然后点击生成。';

  @override
  String get latestResult => '最新结果';

  @override
  String get galleryEmpty => '还没有生成记录';

  @override
  String queueSummary(int running, int pending) {
    return '$running 个运行中 · $pending 个排队中';
  }

  @override
  String get refresh => '刷新';

  @override
  String get interrupt => '中断';

  @override
  String get clearQueue => '清空队列';

  @override
  String get queueEmpty => '队列为空';

  @override
  String get untitledJob => '（无提示词）';

  @override
  String imageCount(int count) {
    return '$count 张图像';
  }

  @override
  String get workflowsIntro => '选择用于生成的 ComfyUI 工作流。导入 API 格式的工作流 JSON 以自定义图。';

  @override
  String get importWorkflow => '导入工作流';

  @override
  String get workflowName => '名称';

  @override
  String get workflowJson => '工作流 JSON（API 格式）';

  @override
  String get loadFromFile => '从文件加载';

  @override
  String get cancel => '取消';

  @override
  String get importAction => '导入';

  @override
  String get invalidWorkflow => '这不是有效的 API 格式工作流';

  @override
  String get workflowImported => '工作流已导入';

  @override
  String get builtinWorkflowName => '文生图';

  @override
  String get builtinWorkflowDesc => '内置 txt2img：checkpoint、提示词、采样器和尺寸';

  @override
  String nodeCount(int count) {
    return '$count 个节点';
  }

  @override
  String get serverSection => 'ComfyUI 服务器';

  @override
  String get serverUrl => '服务器地址';

  @override
  String get invalidServerUrl => '请输入有效的 http(s) 地址';

  @override
  String get testConnection => '测试连接';

  @override
  String serverOk(String version, String device) {
    return '已连接 · $version，设备 $device';
  }

  @override
  String get serverFailed => '无法连接服务器';

  @override
  String get serverHint => '指向一个正在运行的 ComfyUI 实例';

  @override
  String get appearanceSection => '外观';

  @override
  String get theme => '主题';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get themeOled => 'OLED';

  @override
  String get accentColor => '主题色';

  @override
  String get language => '语言';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get aboutSection => '关于';

  @override
  String versionLabel(String version) {
    return '版本 $version';
  }

  @override
  String get checkUpdates => '检查更新';

  @override
  String get updateChecking => '正在检查…';

  @override
  String get updateFailed => '检查更新失败';

  @override
  String updateAvailable(String version) {
    return '新版本 $version 可用';
  }

  @override
  String get upToDate => '已是最新';

  @override
  String getUpdate(String version) {
    return '获取 $version';
  }

  @override
  String get releasesLink => '所有版本';

  @override
  String get sourceLink => '源代码';

  @override
  String get saveImage => '保存图像';

  @override
  String get delete => '删除';

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
    return '模型 $model · 种子 $seed · $steps 步 · CFG $cfg · $sampler/$scheduler · $size';
  }
}
