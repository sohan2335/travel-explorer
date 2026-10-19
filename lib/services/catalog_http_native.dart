import 'dart:io';
import 'dart:convert';

Future<String> getText(String url, Map<String, String> headers) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 12);
  try {
    final request = await client.getUrl(Uri.parse(url));
    headers.forEach((key, value) => request.headers.set(key, value));
    final response = await request.close();
    if (response.statusCode != 200)
      throw HttpException('Catalog HTTP ${response.statusCode}');
    return await response.transform(utf8.decoder).join();
  } finally {
    client.close(force: true);
  }
}
