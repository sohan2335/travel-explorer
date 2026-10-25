import 'local_store_native.dart'
    if (dart.library.js_interop) 'local_store_web.dart'
    as platform;

/// Two operations keep storage separate from the app's travel logic.
abstract class LocalStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}

class DeviceStore implements LocalStore {
  @override
  Future<String?> read(String key) => platform.readValue(key);
  @override
  Future<void> write(String key, String value) =>
      platform.writeValue(key, value);
}

/// Tests can share one MemoryStore between two controllers to simulate reopening.
class MemoryStore implements LocalStore {
  final values = <String, String>{};
  @override
  Future<String?> read(String key) async => values[key];
  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }
}
