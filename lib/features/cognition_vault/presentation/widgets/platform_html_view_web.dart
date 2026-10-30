import 'dart:js_interop';
import 'dart:ui_web' as ui_web;
import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

class WebPlatformHtmlView extends StatefulWidget {
  final String viewKey;
  final String htmlContent;

  const WebPlatformHtmlView({
    super.key,
    required this.viewKey,
    required this.htmlContent,
  });

  @override
  State<WebPlatformHtmlView> createState() => _WebPlatformHtmlViewState();
}

class _WebPlatformHtmlViewState extends State<WebPlatformHtmlView> {
  static final Set<String> _registeredViews = <String>{};
  late String _currentViewType;

  @override
  void initState() {
    super.initState();
    _registerView();
  }

  @override
  void didUpdateWidget(covariant WebPlatformHtmlView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewKey != widget.viewKey ||
        oldWidget.htmlContent != widget.htmlContent) {
      _registerView();
    }
  }

  void _registerView() {
    _currentViewType = 'html_tool_${widget.viewKey}';
    if (!_registeredViews.contains(_currentViewType)) {
      _registeredViews.add(_currentViewType);
      final content = widget.htmlContent;
      ui_web.platformViewRegistry.registerViewFactory(
        _currentViewType,
        (int id, {Object? params}) {
          final iframe = web.HTMLIFrameElement();
          iframe.srcdoc = content.toJS;
          iframe.style.border = 'none';
          iframe.style.width = '100%';
          iframe.style.height = '100%';
          iframe.style.backgroundColor = '#0B0F19';
          iframe.allow = 'fullscreen; clipboard-read; clipboard-write';
          return iframe;
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(
      key: ValueKey(_currentViewType),
      viewType: _currentViewType,
    );
  }
}

Widget buildPlatformHtmlView({
  required String viewKey,
  required String htmlContent,
}) {
  return WebPlatformHtmlView(
    viewKey: viewKey,
    htmlContent: htmlContent,
  );
}

Future<void> openPlatformHtmlExternal({
  required String htmlContent,
  String? localFilePath,
}) async {
  try {
    final blob = web.Blob(
      [htmlContent.toJS].toJS,
      web.BlobPropertyBag(type: 'text/html'),
    );
    final blobUrl = web.URL.createObjectURL(blob);
    web.window.open(blobUrl, '_blank');
  } catch (e) {
    debugPrint('[PlatformHtmlView] Error opening blob: $e');
  }
}
