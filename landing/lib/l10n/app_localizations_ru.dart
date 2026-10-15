// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class LandingLocalizationsRu extends LandingLocalizations {
  LandingLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get tagline => 'Простой клиент ComfyUI';

  @override
  String get hero => 'Опишите и получите изображение.';

  @override
  String get sub =>
      'SimpleUI превращает сервер ComfyUI в генератор изображений с одной строкой ввода.';

  @override
  String get openApp => 'Открыть приложение';

  @override
  String get getDownloads => 'Скачать';

  @override
  String get featuresTitle => 'Почему SimpleUI';

  @override
  String get feature1Title => 'Одна строка ввода';

  @override
  String get feature1Body =>
      'Введите описание и нажмите «Создать». Без графов и проводов.';

  @override
  String get feature2Title => 'Все платформы';

  @override
  String get feature2Body =>
      'Linux, macOS, Windows, Android, iOS и веб из одной сборки.';

  @override
  String get feature3Title => 'Ваш сервер, ваши правила';

  @override
  String get feature3Body =>
      'Укажите любой инстанс ComfyUI. Свои воркфлоу, сэмплеры и сиды.';

  @override
  String get downloadsTitle => 'Загрузки';

  @override
  String get downloadsSub => 'Свежие сборки прямо из ленты релизов.';

  @override
  String get loadingReleases => 'Загрузка релизов…';

  @override
  String get noReleases => 'Релизов пока нет.';

  @override
  String get releasesError => 'Не удалось загрузить релизы.';

  @override
  String get gitlabReleases => 'Релизы на GitLab';

  @override
  String get flatpakHint => 'Одна команда для Linux:';

  @override
  String get sourceLink => 'Исходники на GitLab';

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
  String get language => 'Язык';

  @override
  String get languageSystem => 'Системный';
}
