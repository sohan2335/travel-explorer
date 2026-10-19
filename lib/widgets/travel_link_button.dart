import 'package:flutter/material.dart';
import '../services/external_link.dart';

class TravelLinkButton extends StatelessWidget {
  const TravelLinkButton(
      {super.key,
      required this.label,
      required this.url,
      this.icon = Icons.open_in_new});
  final String label;
  final Uri url;
  final IconData icon;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        onPressed: () => openTravelLink(context, url),
        icon: Icon(icon, size: 18),
        label: Text(label),
      );
}
