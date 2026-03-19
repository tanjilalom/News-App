import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

String? normalizeExternalUrl(String rawUrl, {String? baseUrl}) {
  final trimmed = rawUrl.trim();
  if (trimmed.isEmpty) {
    return null;
  }

  final parsed = Uri.tryParse(trimmed);
  if (parsed != null && parsed.hasScheme) {
    return parsed.toString();
  }

  if (baseUrl == null || baseUrl.isEmpty) {
    return null;
  }

  final resolved = Uri.parse(baseUrl).resolve(trimmed);
  return resolved.toString();
}

Future<void> openExternalLink(
  BuildContext context,
  String rawUrl, {
  String? baseUrl,
}) async {
  final normalizedUrl = normalizeExternalUrl(rawUrl, baseUrl: baseUrl);
  if (normalizedUrl == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invalid article link')),
    );
    return;
  }

  final uri = Uri.tryParse(normalizedUrl);
  if (uri == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invalid article link')),
    );
    return;
  }

  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!launched && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open the link')),
    );
  }
}
