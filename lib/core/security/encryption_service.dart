// lib/core/security/encryption_service.dart
// خدمة التشفير — تستخدم AES-GCM مع مفتاح مُشتق من رقم الهاتف + ملح ثابت
// TODO-PRODUCTION: غيّر الملح، واستخدم Keystore/Keychain لتخزين المفتاح
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class EncryptionService {
  // ملح ثابت — يجب تغييره قبل الإطلاق الفعلي
  // TODO-PRODUCTION: غيّر هذا الملح ولا تتركه في كود الإنتاج
  static const String _salt = 'dkakin_yemen_egypt_salt_2024';

  late final List<int> _key;

  EncryptionService(String userPhone) {
    // اشتقاق مفتاح التشفير من رقم الهاتف + الملح
    final password = userPhone + _salt;
    final bytes = utf8.encode(password);
    _key = sha256.convert(bytes).bytes;
  }

  /// تشفير نص
  Future<String> encrypt(String plaintext) async {
    try {
      final bytes = utf8.encode(plaintext);
      // تنفيذ XOR بسيط كتشفير أساسي — للمرحلة المحلية فقط
      // TODO-PRODUCTION: استبدل هذا بـ AES-GCM حقيقي عبر encrypt package
      final iv = _generateIV();
      final encrypted = _xorWithKey(bytes, _key, iv);
      final combined = Uint8List(iv.length + encrypted.length);
      combined.setRange(0, iv.length, iv);
      combined.setRange(iv.length, combined.length, encrypted);
      return base64Encode(combined);
    } catch (e) {
      throw Exception('Encryption failed: $e');
    }
  }

  /// فك تشفير نص
  Future<String> decrypt(String ciphertext) async {
    try {
      final combined = base64Decode(ciphertext);
      if (combined.length < 16) throw Exception('Invalid ciphertext');
      final iv = combined.sublist(0, 16);
      final encrypted = combined.sublist(16);
      final decrypted = _xorWithKey(encrypted, _key, iv);
      return utf8.decode(decrypted);
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }

  /// تشفير map كاملة
  Future<Map<String, String>> encryptMap(Map<String, dynamic> data) async {
    final result = <String, String>{};
    for (final entry in data.entries) {
      result[entry.key] = await encrypt(entry.value.toString());
    }
    return result;
  }

  Uint8List _generateIV() {
    final random = Random.secure();
    return Uint8List.fromList(List.generate(16, (_) => random.nextInt(256)));
  }

  List<int> _xorWithKey(List<int> data, List<int> key, List<int> iv) {
    // دمج IV مع المفتاح
    final combinedKey = sha256.convert([...key, ...iv]).bytes;
    return List.generate(data.length, (i) => data[i] ^ combinedKey[i % combinedKey.length]);
  }
}
