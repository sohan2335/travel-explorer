import 'package:flutter/material.dart';

/// Bundled photos work offline; remote URLs retain a loading/error fallback.
class DestinationImage extends StatelessWidget {
  const DestinationImage({super.key, required this.url, required this.label});

  final String url;
  final String label;

  @override
  Widget build(BuildContext context) {
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        semanticLabel: label,
        errorBuilder: (context, error, stackTrace) => _placeholder(context),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      semanticLabel: label,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : _placeholder(context, loading: true),
      errorBuilder: (context, error, stackTrace) => _placeholder(context),
    );
  }

  Widget _placeholder(BuildContext context, {bool loading = false}) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Center(
        child: loading
            ? const SizedBox.square(
                dimension: 28, child: CircularProgressIndicator(strokeWidth: 2))
            : const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.landscape_outlined, size: 40),
                  SizedBox(height: 8),
                  Text('Photo unavailable'),
                ],
              ),
      ),
    );
  }
}
