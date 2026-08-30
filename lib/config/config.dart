import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> loadEnv() async {
  try {
    await dotenv.load(fileName: '.env');
    debugPrint('Loaded .env file');
  } catch (e) {
    debugPrint('Error loading .env file: $e');
  }
}
