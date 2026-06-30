// lib/main.dart
// نقطة دخول التطبيق — تهيئة الاعتماديات ثم تشغيل التطبيق
import 'package:flutter/material.dart';
import 'app.dart';
import 'injection.dart';

void main() async {
  // تأكد من تهيئة Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة جميع الاعتماديات
  await configureDependencies();

  // تشغيل التطبيق
  runApp(const DkakinApp());
}
