import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/database/hive_storage.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../data/models/local_html_tool.dart';
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
      if (!kIsWeb && _currentTool.localFilePath.isNotEmpty) {
        final file = File(_currentTool.localFilePath);
        if (await file.exists()) {
          await controller.loadFile(_currentTool.localFilePath);
          return;
        }
      }

      // Fallback: load raw HTML string
      if (_currentTool.htmlContent != null && _currentTool.htmlContent!.isNotEmpty) {
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

  void _reload() {
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
        _controller!.reload();
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
        String content;
        try {
          content = utf8.decode(bytes);
        } catch (_) {
          content = String.fromCharCodes(bytes);
        }
        final updated = _currentTool.copyWith(htmlContent: content);
        await _storage.saveHtmlTool(updated);
        setState(() {
          _currentTool = updated;
          _loadError = null;
          _isLoading = false;
        });
        widget.onToolUpdated?.call(updated);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Updated content for "${updated.title}".'),
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
        title: const Text('Rename HTML Tool', style: AppTextStyles.heading),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: AppTextStyles.bodyMedium,
              decoration: const InputDecoration(
                labelText: 'Tool Title',
                filled: true,
                fillColor: AppColors.surfaceElevated,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: categoryController,
              style: AppTextStyles.bodyMedium,
              decoration: const InputDecoration(
                labelText: 'Category / Tag',
                filled: true,
                fillColor: AppColors.surfaceElevated,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCEL', style: TextStyle(color: AppColors.textMuted)),
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
                    content: Text('Renamed to "$newTitle".'),
                    backgroundColor: AppColors.surfaceElevated,
                  ),
                );
              }
            },
            child: const Text('SAVE'),
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
        title: const Text('Delete HTML Tool?', style: AppTextStyles.heading),
        content: Text(
          'Are you sure you want to delete "${_currentTool.title}"? The offline file and all associated DOM state will be removed.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('CANCEL', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.roseDanger),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('DELETE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!kIsWeb && _currentTool.localFilePath.isNotEmpty) {
        try {
          final file = File(_currentTool.localFilePath);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          debugPrint('[LocalHtmlViewer] File deletion error: $e');
        }
      }

      await _storage.deleteHtmlTool(_currentTool.id);
      widget.onToolDeleted?.call();

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted "${_currentTool.title}".'),
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
            tooltip: 'Reload Dashboard',
            onPressed: _reload,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, size: 20, color: AppColors.textPrimary),
            color: AppColors.surfaceElevated,
            onSelected: (value) {
              if (value == 'rename') _showRenameDialog();
              if (value == 'delete') _confirmDelete();
              if (value == 'external') _openInExternalBrowser();
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'rename',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 16, color: AppColors.textPrimary),
                    SizedBox(width: 10),
                    Text('Rename Tool', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'external',
                child: Row(
                  children: [
                    Icon(Icons.open_in_browser_rounded, size: 16, color: AppColors.textPrimary),
                    SizedBox(width: 10),
                    Text('Open in Browser', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.roseDanger),
                    SizedBox(width: 10),
                    Text('Delete Tool', style: TextStyle(fontSize: 12, color: AppColors.roseDanger)),
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
                    Text('Unable to render offline tool', style: AppTextStyles.heading),
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
                          label: const Text('RETRY'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: _reimportHtmlContent,
                          icon: const Icon(Icons.file_upload_outlined, size: 16),
                          label: const Text('RE-SELECT FILE'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            side: const BorderSide(color: AppColors.borderMedium),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          else if (kIsWeb)
            Positioned.fill(
              child: buildPlatformHtmlView(
                viewKey: '${_currentTool.id}_$_reloadCount',
                htmlContent: _currentTool.htmlContent ?? '',
              ),
            )
          else if (_controller != null)
            Positioned.fill(
              child: WebViewWidget(controller: _controller!),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: AppColors.shieldPrimary),
            ),
          if (_isLoading)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                minHeight: 2.5,
              ),
            ),
        ],
      ),
    );
  }
}
