Future<Map<String, dynamic>?> authRequest(
  String path, [
  Map<String, dynamic>? data,
]) async => throw UnsupportedError(
  'Please use the web app to sign in. Native sign-in is not configured yet.',
);
void navigateToAuth(String url) =>
    throw UnsupportedError('Use the web app to sign in.');
