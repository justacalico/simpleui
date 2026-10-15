// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'SimpleUI';

  @override
  String get navGenerate => 'Создать';

  @override
  String get navGallery => 'Галерея';

  @override
  String get navQueue => 'Очередь';

  @override
  String get navWorkflows => 'Воркфлоу';

  @override
  String get navSettings => 'Настройки';

  @override
  String get navMore => 'Ещё';

  @override
  String get expandSidebar => 'Развернуть панель';

  @override
  String get collapseSidebar => 'Свернуть панель';

  @override
  String get generateHeadline => 'Что вы хотите создать?';

  @override
  String get promptHint => 'Опишите нужное изображение…';

  @override
  String get advancedOptions => 'Дополнительно';

  @override
  String get generate => 'Создать';

  @override
  String get negativePrompt => 'Негативный промпт';

  @override
  String get model => 'Модель';

  @override
  String get sampler => 'Сэмплер';

  @override
  String get scheduler => 'Планировщик';

  @override
  String get steps => 'Шаги';

  @override
  String get cfg => 'CFG';

  @override
  String get seed => 'Сид';

  @override
  String get randomSeed => 'Случайный сид';

  @override
  String get keepSeed => 'Фиксировать сид';

  @override
  String batchCount(int count) {
    return 'Пакет: $count';
  }

  @override
  String get jobQueued => 'В очереди';

  @override
  String jobRunning(String progress) {
    return 'Создание… $progress%';
  }

  @override
  String get jobDone => 'Готово';

  @override
  String get jobFailed => 'Ошибка';

  @override
  String get jobInterrupted => 'Прервано';

  @override
  String get emptyResults =>
      'Пока пусто. Опишите изображение и нажмите «Создать».';

  @override
  String get latestResult => 'Последний результат';

  @override
  String get galleryEmpty => 'Пока нет генераций';

  @override
  String queueSummary(int running, int pending) {
    return 'Выполняется: $running · в очереди: $pending';
  }

  @override
  String get refresh => 'Обновить';

  @override
  String get interrupt => 'Прервать';

  @override
  String get clearQueue => 'Очистить очередь';

  @override
  String get queueEmpty => 'Очередь пуста';

  @override
  String get untitledJob => '(без промпта)';

  @override
  String imageCount(int count) {
    return 'изображений: $count';
  }

  @override
  String get workflowsIntro =>
      'Выберите воркфлоу ComfyUI для генерации. Импортируйте JSON в API-формате, чтобы настроить граф.';

  @override
  String get importWorkflow => 'Импорт воркфлоу';

  @override
  String get workflowName => 'Название';

  @override
  String get workflowJson => 'JSON воркфлоу (API-формат)';

  @override
  String get loadFromFile => 'Загрузить из файла';

  @override
  String get cancel => 'Отмена';

  @override
  String get importAction => 'Импорт';

  @override
  String get invalidWorkflow => 'Это не похоже на воркфлоу в API-формате';

  @override
  String get workflowImported => 'Воркфлоу импортирован';

  @override
  String get builtinWorkflowName => 'Текст в изображение';

  @override
  String get builtinWorkflowDesc =>
      'Встроенный txt2img: чекпоинт, промпты, сэмплер и размер';

  @override
  String nodeCount(int count) {
    return 'Узлов: $count';
  }

  @override
  String get serverSection => 'Сервер ComfyUI';

  @override
  String get serverUrl => 'Адрес сервера';

  @override
  String get invalidServerUrl => 'Введите корректный http(s) адрес';

  @override
  String get testConnection => 'Проверить соединение';

  @override
  String serverOk(String version, String device) {
    return 'Подключено · $version на $device';
  }

  @override
  String get serverFailed => 'Не удалось подключиться к серверу';

  @override
  String get serverHint => 'Укажите запущенный экземпляр ComfyUI';

  @override
  String get appearanceSection => 'Внешний вид';

  @override
  String get theme => 'Тема';

  @override
  String get themeSystem => 'Системная';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get themeOled => 'OLED';

  @override
  String get accentColor => 'Акцентный цвет';

  @override
  String get language => 'Язык';

  @override
  String get languageSystem => 'Системный';

  @override
  String get aboutSection => 'О приложении';

  @override
  String versionLabel(String version) {
    return 'Версия $version';
  }

  @override
  String get checkUpdates => 'Проверить обновления';

  @override
  String get updateChecking => 'Проверка…';

  @override
  String get updateFailed => 'Не удалось проверить обновления';

  @override
  String updateAvailable(String version) {
    return 'Доступна версия $version';
  }

  @override
  String get upToDate => 'Установлена последняя версия';

  @override
  String getUpdate(String version) {
    return 'Скачать $version';
  }

  @override
  String get releasesLink => 'Все релизы';

  @override
  String get sourceLink => 'Исходный код';

  @override
  String get saveImage => 'Сохранить изображение';

  @override
  String get delete => 'Удалить';

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
    return 'Модель $model · сид $seed · шагов: $steps · CFG $cfg · $sampler/$scheduler · $size';
  }
}
