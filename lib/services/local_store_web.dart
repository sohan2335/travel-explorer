import 'dart:js_interop';

@JS('window.localStorage')
external _BrowserStorage get _storage;

extension type _BrowserStorage(JSObject _) implements JSObject {
  external JSString? getItem(JSString key);
  external void setItem(JSString key, JSString value);
}

Future<String?> readValue(String key) async =>
    _storage.getItem(key.toJS)?.toDart;
Future<void> writeValue(String key, String value) async {
  _storage.setItem(key.toJS, value.toJS);
}
