import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

Widget buildPlatformHtmlView({
  required String viewKey,
  required String htmlContent,
}) {
  return const SizedBox.shrink();
}

Future<void> openPlatformHtmlExternal({
  required String htmlContent,
  String? localFilePath,
}) async {
  try {
    if (localFilePath != null && localFilePath.isNotEmpty) {
      final uri = Uri.file(localFilePath);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    }
    if (htmlContent.isNotEmpty) {
      final uri = Uri.dataFromString(htmlContent, mimeType: 'text/html');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  } catch (e) {
    debugPrint('[PlatformHtmlView] Error launching external URL: $e');
  }
}
