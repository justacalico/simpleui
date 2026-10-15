// coverage:ignore-file
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';

Future<String?> pickWorkflowFile() async {
  const type = XTypeGroup(label: 'JSON', extensions: ['json']);
  final file = await openFile(acceptedTypeGroups: [type]);
  return file?.readAsString();
}

Future<bool> saveImageFile(String name, Uint8List bytes) async {
  final location = await getSaveLocation(suggestedName: name);
  if (location == null) return false;
  final file = XFile.fromData(bytes, name: name);
  await file.saveTo(location.path);
  return true;
}
