import 'dart:typed_data';

typedef PickWorkflowFile = Future<String?> Function();
typedef SaveImageFile = Future<bool> Function(String name, Uint8List bytes);
