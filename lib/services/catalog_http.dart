import 'catalog_http_native.dart'
    if (dart.library.js_interop) 'catalog_http_web.dart'
    as platform;

Future<String> catalogGet(Uri url, {Map<String, String> headers = const {}}) =>
    platform
        .getText(url.toString(), headers)
        .timeout(const Duration(seconds: 15));
