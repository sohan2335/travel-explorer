import 'dart:js_interop';

@JS('fetch')
external JSPromise<_Response> _fetch(JSString url, _Options options);
extension type _Options._(JSObject _) implements JSObject {
  external factory _Options({JSObject headers});
}
extension type _Response(JSObject _) implements JSObject {
  external int get status;
  external JSPromise<JSString> text();
}
Future<String> getText(String url, Map<String, String> headers) async {
  final response =
      await _fetch(url.toJS, _Options(headers: headers.jsify() as JSObject))
          .toDart;
  if (response.status != 200)
    throw StateError('Catalog HTTP ${response.status}');
  return (await response.text().toDart).toDart;
}
