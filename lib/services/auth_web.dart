import 'dart:convert';
import 'dart:js_interop';
import 'place_catalog.dart';

@JS('fetch')
external JSPromise<_Response> _fetch(JSString url, _Options options);
@JS('window.location.assign')
external void _navigate(JSString url);
extension type _Options._(JSObject _) implements JSObject {
  external factory _Options(
      {String method, String credentials, JSObject headers, String? body});
}
extension type _Response(JSObject _) implements JSObject {
  external int get status;
  external JSPromise<JSString> text();
}
// The browser keeps the secure session cookie; passwords are never saved locally.
Future<Map<String, dynamic>?> authRequest(String path,
    [Map<String, dynamic>? data]) async {
  final r = await _fetch(
          '${PlaceCatalog.authUrl}/$path'.toJS,
          _Options(
              method: data == null ? 'GET' : 'POST',
              credentials: 'include',
              headers: {'Content-Type': 'application/json'}.jsify() as JSObject,
              body: data == null ? null : jsonEncode(data)))
      .toDart
      .timeout(const Duration(seconds: 20));
  final raw = (await r.text().toDart).toDart;
  final value = raw.isEmpty ? null : jsonDecode(raw);
  if (r.status >= 400)
    throw StateError(value is Map
        ? (value['message'] ??
                value['error'] ??
                'Sign in failed. Please try again.')
            .toString()
        : 'Sign in is unavailable.');
  return value is Map ? Map<String, dynamic>.from(value) : null;
}

void navigateToAuth(String url) {
  final uri = Uri.parse(url);
  if (uri.scheme != 'https' ||
      !(uri.host == 'accounts.google.com' || uri.host.endsWith('.neon.tech')))
    throw StateError('Unexpected sign-in destination');
  _navigate(url.toJS);
}
