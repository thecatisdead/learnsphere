import 'dart:io';
import 'package:crypto/crypto.dart';

class FileHashService {
  static Future<String> sha256File(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();

    return sha256.convert(bytes).toString();
  }
}