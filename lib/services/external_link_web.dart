import 'dart:js_interop';

@JS('window.open')
external _BrowserWindow? _openWindow(JSString url, JSString target);

extension type _BrowserWindow(JSObject _) implements JSObject {
  external set opener(JSAny? value);
}

Future<void> openUrl(String url) async {
  // This is called directly from a button tap, so browsers can open a new tab.
  final opened = _openWindow(url.toJS, '_blank'.toJS);
  if (opened == null) throw StateError('The browser did not open the link.');
  opened.opener = null;
}
