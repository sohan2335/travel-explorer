import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
    if (url.isEmpty) return _placeholder(context);
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      width: double.infinity,
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      imageBuilder: (context, provider) => Image(
        image: provider,
        fit: BoxFit.cover,
        width: double.infinity,
        semanticLabel: label,
      ),
      placeholder: (context, _) => _placeholder(context, loading: true),
      errorWidget: (context, _, error) => _placeholder(context),
    );
  }

  Widget _placeholder(BuildContext context, {bool loading = false}) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF37235F), Color(0xFF19191C)],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                loading ? Icons.photo_outlined : Icons.landscape_outlined,
                color: const Color(0xFFC3AEFF),
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
