import 'package:flutter/services.dart';

const _channel = MethodChannel('travel_explorer/storage');
Future<String?> readValue(String key) =>
    _channel.invokeMethod<String>('read', key);
Future<void> writeValue(String key, String value) =>
    _channel.invokeMethod<void>('write', {'key': key, 'value': value});
