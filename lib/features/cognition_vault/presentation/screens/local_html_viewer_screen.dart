import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/database/hive_storage.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../data/models/local_html_tool.dart';
import '../../data/services/html_tool_storage_service.dart';
import '../widgets/platform_html_view.dart';

/// LocalHtmlViewerScreen renders offline HTML files and interactive dashboards
/// across Mobile, Desktop, and Web with full JavaScript execution, DOM storage,
/// touch interactions, and an executive management toolbar (refresh, rename, delete).
class LocalHtmlViewerScreen extends StatefulWidget {
  final LocalHtmlTool tool;
  final VoidCallback? onToolDeleted;
  final ValueChanged<LocalHtmlTool>? onToolUpdated;

  const LocalHtmlViewerScreen({
    super.key,
    required this.tool,
    this.onToolDeleted,
    this.onToolUpdated,
  });

  static Future<void> open(
    BuildContext context, {
    required LocalHtmlTool tool,
    VoidCallback? onToolDeleted,
    ValueChanged<LocalHtmlTool>? onToolUpdated,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LocalHtmlViewerScreen(
          tool: tool,
          onToolDeleted: onToolDeleted,
          onToolUpdated: onToolUpdated,
        ),
      ),
    );
  }

  @override
  State<LocalHtmlViewerScreen> createState() => _LocalHtmlViewerScreenState();
}

class _LocalHtmlViewerScreenState extends State<LocalHtmlViewerScreen> {
  final HiveStorage _storage = HiveStorage();
  final HtmlToolStorageService _storageService = HtmlToolStorageService();
  late LocalHtmlTool _currentTool;

  WebViewController? _controller;
  bool _isLoading = true;
  String? _loadError;
  int _reloadCount = 0;

  @override
  void initState() {
    super.initState();
    _currentTool = widget.tool;
    if (kIsWeb) {
      _initWeb();
    } else {
      _initWebView();
    }
  }

  void _initWeb() {
    if (_currentTool.htmlContent == null || _currentTool.htmlContent!.trim().isEmpty) {
      setState(() {
        _isLoading = false;
        _loadError = 'Offline HTML content is unavailable on this device.';
      });
    } else {
      setState(() {
        _isLoading = false;
        _loadError = null;
      });
    }
  }

  void _initWebView() {
    try {
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(AppColors.background)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (_) {
              if (mounted) setState(() => _isLoading = true);
            },
            onPageFinished: (_) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _loadError = null;
                });
              }
            },
            onWebResourceError: (error) {
              debugPrint('[LocalHtmlViewer] Web error: ${error.description}');
            },
          ),
        );

      // Enable Android-specific local offline file access, content access, and media playback
      if (!kIsWeb && controller.platform is AndroidWebViewController) {
        AndroidWebViewController.enableDebugging(true);
        final androidController = controller.platform as AndroidWebViewController;
        androidController.setAllowFileAccess(true);
        androidController.setAllowContentAccess(true);
        androidController.setMediaPlaybackRequiresUserGesture(false);
      }

      _loadContent(controller);
      _controller = controller;
    } catch (e) {
      debugPrint('[LocalHtmlViewer] Controller setup error: $e');
      setState(() {
        _isLoading = false;
        _loadError = e.toString();
      });
    }
  }

  Future<void> _loadContent(WebViewController controller) async {
    try {
      if (!kIsWeb) {
        // Ensure the file is physically present in app_html_tools/ sandbox
        final savedPath = await _storageService.prepareFileForLoading(_currentTool);
        if (savedPath.isNotEmpty && await File(savedPath).exists()) {
          // Invalidate cache before loading so CSS/JS changes reflect immediately
          await controller.clearCache();
          await controller.loadFile(savedPath);
          return;
        }
      }

      // Fallback: load raw HTML string
      if (_currentTool.htmlContent != null && _currentTool.htmlContent!.isNotEmpty) {
        await controller.clearCache();
        await controller.loadHtmlString(_currentTool.htmlContent!);
      } else {
        setState(() {
          _isLoading = false;
          _loadError = 'Offline HTML content is unavailable on this device.';
        });
      }
    } catch (e) {
      debugPrint('[LocalHtmlViewer] Load content error: $e');
      if (_currentTool.htmlContent != null) {
        await controller.loadHtmlString(_currentTool.htmlContent!);
      } else {
        setState(() {
          _isLoading = false;
          _loadError = 'Failed to load local HTML file: $e';
        });
      }
    }
  }

  Future<void> _reload() async {
    HapticService.selectionClick();
    if (kIsWeb) {
      setState(() {
        _isLoading = true;
        _reloadCount++;
        _loadError = null;
      });
      Future.delayed(const Duration(milliseconds: 250), () {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      });
    } else {
      if (_controller != null) {
        await _controller!.clearCache();
        final savedPath = await _storageService.prepareFileForLoading(_currentTool);
        if (savedPath.isNotEmpty && await File(savedPath).exists()) {
          await _controller!.loadFile(savedPath);
        } else {
          await _controller!.reload();
        }
      } else {
        _initWebView();
      }
    }
  }

  Future<void> _reimportHtmlContent() async {
    HapticService.selectionClick();
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['html', 'htm'],
      );
      if (files.isNotEmpty) {
        final file = files.first;
        final bytes = await file.readAsBytes();

        final result = await _storageService.importOrOverwriteTool(
          sourceFilePath: file.path,
          originalFileName: file.name,
          bytes: bytes,
          title: _currentTool.title,
          category: _currentTool.category,
          description: _currentTool.description,
        );

        setState(() {
          _currentTool = result.tool;
          _loadError = null;
          _isLoading = false;
        });
        widget.onToolUpdated?.call(result.tool);

        if (_controller != null && !kIsWeb) {
          await _controller!.clearCache();
          await _controller!.loadFile(result.tool.localFilePath);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${context.loc.toolOverwrittenNotice} ("${result.tool.title}").',
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: AppColors.surfaceElevated,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('[LocalHtmlViewer] Re-import error: $e');
    }
  }

  void _showRenameDialog() {
    HapticService.selectionClick();
    final titleController = TextEditingController(text: _currentTool.title);
    final categoryController = TextEditingController(text: _currentTool.category);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(context.loc.toolTitleLabel, style: AppTextStyles.heading),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: context.loc.toolTitleLabel,
                filled: true,
                fillColor: AppColors.surfaceElevated,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: categoryController,
              decoration: InputDecoration(
                labelText: context.loc.toolCategoryLabel,
                filled: true,
                fillColor: AppColors.surfaceElevated,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.loc.cancelButton, style: const TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newTitle = titleController.text.trim();
              if (newTitle.isEmpty) return;

              final updated = _currentTool.copyWith(
                title: newTitle,
                category: categoryController.text.trim().isEmpty
                    ? _currentTool.category
                    : categoryController.text.trim(),
              );

              await _storage.saveHtmlTool(updated);
              setState(() => _currentTool = updated);
              widget.onToolUpdated?.call(updated);

              if (mounted) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.loc.renamedToolNotice(newTitle)),
                    backgroundColor: AppColors.surfaceElevated,
                  ),
                );
              }
            },
            child: Text(context.loc.saveAction),
          ),
        ],
      ),
    );
  }

  void _confirmDelete() async {
    HapticService.selectionClick();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(context.loc.deleteToolTitle, style: AppTextStyles.heading),
        content: Text(
          '${context.loc.deleteToolConfirm}\n\n"${_currentTool.title}" (${_currentTool.fileName})',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.loc.cancelButton, style: const TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.roseDanger),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(context.loc.deleteAction, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _storageService.deleteTool(_currentTool);
      widget.onToolDeleted?.call();

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.loc.toolDeletedNotice} ("${_currentTool.title}")'),
            backgroundColor: AppColors.surfaceElevated,
          ),
        );
      }
    }
  }

  void _openInExternalBrowser() async {
    HapticService.selectionClick();
    if (_currentTool.htmlContent != null && _currentTool.htmlContent!.isNotEmpty) {
      await openPlatformHtmlExternal(
        htmlContent: _currentTool.htmlContent!,
        localFilePath: _currentTool.localFilePath,
      );
    } else if (!kIsWeb && _currentTool.localFilePath.isNotEmpty) {
      await openPlatformHtmlExternal(
        htmlContent: '',
        localFilePath: _currentTool.localFilePath,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'OFFLINE TOOL • ${_currentTool.category.toUpperCase()}',
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              _currentTool.title,
              style: AppTextStyles.heading.copyWith(fontSize: 15),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20, color: AppColors.textPrimary),
            tooltip: context.loc.reloadTool,
            onPressed: _reload,
          ),
          IconButton(
            icon: const Icon(Icons.file_upload_outlined, size: 20, color: AppColors.textPrimary),
            tooltip: context.loc.reimportTool,
            onPressed: _reimportHtmlContent,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, size: 20, color: AppColors.textPrimary),
            color: AppColors.surfaceElevated,
            onSelected: (value) {
              if (value == 'rename') _showRenameDialog();
              if (value == 'reimport') _reimportHtmlContent();
              if (value == 'delete') _confirmDelete();
              if (value == 'external') _openInExternalBrowser();
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'rename',
                child: Row(
                  children: [
                    const Icon(Icons.edit_outlined, size: 16, color: AppColors.textPrimary),
                    const SizedBox(width: 10),
                    Text(context.loc.renameToolAction, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'reimport',
                child: Row(
                  children: [
                    const Icon(Icons.published_with_changes_rounded, size: 16, color: Color(0xFF10B981)),
                    const SizedBox(width: 10),
                    Text(context.loc.reimportTool, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'external',
                child: Row(
                  children: [
                    const Icon(Icons.open_in_browser_rounded, size: 16, color: AppColors.textPrimary),
                    const SizedBox(width: 10),
                    Text(context.loc.openInBrowserAction, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.roseDanger),
                    const SizedBox(width: 10),
                    Text(context.loc.deleteAction, style: const TextStyle(fontSize: 12, color: AppColors.roseDanger)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_loadError != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimens.space24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 40, color: AppColors.roseDanger),
                    const SizedBox(height: 12),
                    Text(context.loc.unableToRenderOfflineTool, style: AppTextStyles.heading),
                    const SizedBox(height: 6),
                    Text(
                      _loadError!,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _reload,
                          icon: const Icon(Icons.refresh_rounded, size: 16),
                          label: Text(context.loc.retryAction),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: _openInExternalBrowser,
                          icon: const Icon(Icons.open_in_browser_rounded, size: 16),
                          label: Text(context.loc.externalBrowserAction),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          else if (kIsWeb)
            buildPlatformHtmlView(
              viewKey: 'web_tool_${_currentTool.id}_$_reloadCount',
              htmlContent: _currentTool.htmlContent ?? '',
            )
          else if (_controller != null)
            WebViewWidget(controller: _controller!),

          if (_isLoading && _loadError == null)
            Container(
              color: AppColors.background,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF10B981), strokeWidth: 2.5),
                    SizedBox(height: 12),
                    Text(
                      'Rendering offline sandbox...',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
