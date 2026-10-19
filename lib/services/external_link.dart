import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'external_link_native.dart'
    if (dart.library.js_interop) 'external_link_web.dart' as platform;

/// Keep platform-specific opening in one place; show a copyable link on failure.
Future<void> openTravelLink(BuildContext context, Uri uri) async {
  if (uri.scheme != 'https')
    throw ArgumentError('Only HTTPS travel links are supported.');
  try {
    await platform.openUrl(uri.toString());
  } catch (_) {
    if (!context.mounted) return;
    await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Open this link in your browser'),
              content:
                  SingleChildScrollView(child: SelectableText(uri.toString())),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close')),
                TextButton(
                    onPressed: () async {
                      await Clipboard.setData(
                          ClipboardData(text: uri.toString()));
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: const Text('Copy link')),
              ],
            ));
  }
}
