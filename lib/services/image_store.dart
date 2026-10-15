import 'dart:convert';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

abstract class ImageStore {
  Future<void> save(String key, Uint8List bytes);
  Future<Uint8List?> read(String key);
  Future<void> delete(String key);
}

class PrefsImageStore implements ImageStore {
  static const _prefix = 'img_';

  final SharedPreferences prefs;

  PrefsImageStore(this.prefs);

  @override
  Future<void> save(String key, Uint8List bytes) =>
      prefs.setString('$_prefix$key', base64Encode(bytes));

  @override
  Future<Uint8List?> read(String key) async {
    final raw = prefs.getString('$_prefix$key');
    if (raw == null) return null;
    try {
      return base64Decode(raw);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> delete(String key) => prefs.remove('$_prefix$key');
}
