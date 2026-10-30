import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/haptic_service.dart';

/// InAppWebViewerScreen opens external web articles, classical texts,
/// and Google Drive PDFs inside an embedded in-app browser with progress tracking.
class InAppWebViewerScreen extends StatefulWidget {
  final String url;
  final String title;
  final String? category;

  const InAppWebViewerScreen({
    super.key,
    required this.url,
    required this.title,
    this.category,
  });

  static Future<void> open(
    BuildContext context, {
    required String url,
    required String title,
    String? category,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => InAppWebViewerScreen(
          url: url,
          title: title,
          category: category,
        ),
      ),
    );
  }

  @override
  State<InAppWebViewerScreen> createState() => _InAppWebViewerScreenState();
}

class _InAppWebViewerScreenState extends State<InAppWebViewerScreen> {
  WebViewController? _webViewController;
  int _loadingProgress = 0;
  bool _isLoading = true;
  String? _pageTitle;
  String? _errorMessage;
  late final String _normalizedUrl;

  @override
  void initState() {
    super.initState();
    _normalizedUrl = _prepareUrl(widget.url);

    if (!kIsWeb) {
      _initWebViewController();
    } else {
      _isLoading = false;
    }
  }

  String _prepareUrl(String raw) {
    var trimmed = raw.trim();
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      trimmed = 'https://$trimmed';
    }
    return trimmed;
  }

  void _initWebViewController() {
    try {
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(AppColors.background)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              if (mounted) {
                setState(() {
                  _loadingProgress = progress;
                  _isLoading = progress < 100;
                });
              }
            },
            onPageStarted: (String url) {
              if (mounted) {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
              }
            },
            onPageFinished: (String url) async {
              if (mounted) {
                String? title;
                try {
                  title = await _webViewController?.getTitle();
                } catch (_) {}
                setState(() {
                  _isLoading = false;
                  if (title != null && title.isNotEmpty) {
                    _pageTitle = title;
                  }
                });
              }
            },
            onWebResourceError: (WebResourceError error) {
              // Ignore non-failing minor sub-resource errors (e.g. ad trackers or favicon errors)
              if (error.isForMainFrame ?? true) {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                    _errorMessage = error.description.isNotEmpty
                        ? error.description
                        : 'Failed to load webpage.';
                  });
                }
              }
            },
          ),
        );

      controller.loadRequest(Uri.parse(_normalizedUrl));
      _webViewController = controller;
    } catch (e) {
      debugPrint('[InAppWebViewerScreen] controller init error: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'In-app viewer unavailable on this platform ($e)';
      });
    }
  }

  String _extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.isNotEmpty ? uri.host : url;
    } catch (_) {
      return url;
    }
  }

  Future<void> _handleBackPress() async {
    HapticService.selectionClick();
    if (_webViewController != null) {
      final canGoBack = await _webViewController!.canGoBack();
      if (canGoBack) {
        await _webViewController!.goBack();
        return;
      }
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _launchExternalBrowser() async {
    HapticService.selectionClick();
    try {
      final uri = Uri.parse(_normalizedUrl);
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open external browser: $e'),
            backgroundColor: AppColors.surfaceElevated,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final domain = _extractDomain(_normalizedUrl);
    final displayTitle = _pageTitle?.isNotEmpty == true
        ? _pageTitle!
        : (widget.title.isNotEmpty ? widget.title : 'External Document');

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBackPress();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
            tooltip: 'Go Back',
            onPressed: _handleBackPress,
          ),
          titleSpacing: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayTitle,
                style: AppTextStyles.titleSmall.copyWith(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 1),
              Row(
                children: [
                  const Icon(
                    Icons.lock_outline_rounded,
                    size: 10,
                    color: AppColors.emeraldSuccess,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      domain,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 10.5,
                        color: AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            if (_webViewController != null)
              IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 20, color: AppColors.textSecondary),
                tooltip: 'Reload',
                onPressed: () {
                  HapticService.selectionClick();
                  _webViewController?.reload();
                },
              ),
            IconButton(
              icon: const Icon(Icons.open_in_browser_rounded, size: 20, color: AppColors.shieldPrimary),
              tooltip: 'Open in external browser',
              onPressed: _launchExternalBrowser,
            ),
            const SizedBox(width: 4),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2.5),
            child: _isLoading
                ? LinearProgressIndicator(
                    value: _loadingProgress > 0 ? _loadingProgress / 100.0 : null,
                    minHeight: 2.5,
                    backgroundColor: AppColors.surfaceElevated,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.shieldPrimary),
                  )
                : const Divider(height: 1, color: AppColors.borderSubtle),
          ),
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (kIsWeb) {
      return _buildWebPlatformFallback();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_webViewController == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.shieldPrimary),
      );
    }

    return Stack(
      children: [
        WebViewWidget(controller: _webViewController!),
        if (_isLoading && _loadingProgress < 40)
          Container(
            color: AppColors.background,
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.shieldPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Loading document secure viewer...',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.amberWarning.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 32,
                color: AppColors.amberWarning,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to Load in Embedded Browser',
              style: AppTextStyles.heading,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'The website refused embedded connection.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    HapticService.selectionClick();
                    setState(() {
                      _errorMessage = null;
                      _isLoading = true;
                    });
                    _webViewController?.reload();
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: Text(context.loc.retryAction),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.borderMedium),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _launchExternalBrowser,
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: Text(context.loc.openInChromeAction),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.shieldPrimary,
                    foregroundColor: AppColors.background,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebPlatformFallback() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.space24),
        child: Container(
          padding: const EdgeInsets.all(AppDimens.space20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.language_rounded, size: 40, color: AppColors.shieldPrimary),
              const SizedBox(height: 14),
              Text(widget.title, style: AppTextStyles.heading, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                _normalizedUrl,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _launchExternalBrowser,
                icon: const Icon(Icons.open_in_browser_rounded, size: 16),
                label: Text(context.loc.launchWebResource),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.shieldPrimary,
                  foregroundColor: AppColors.background,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
