// permissions.dart
import 'package:android_intent_plus/android_intent.dart';
import 'dart:io';

Future<void> requestExactAlarmPermission() async {
  if (Platform.isAndroid) {
    const intent = AndroidIntent(
      action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
    );
    await intent.launch();
  }
}
