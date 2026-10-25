import 'package:flutter/services.dart';

Future<void> openUrl(String url) async {
  await const MethodChannel(
    'travel_explorer/links',
  ).invokeMethod<void>('openUrl', url);
}
