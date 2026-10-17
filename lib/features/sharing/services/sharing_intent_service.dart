import 'dart:async';
import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../presentation/widgets/incoming_share_modal_sheet.dart';

/// SharingIntentService listens for system share intents and triggers
/// the contextual "Save to Sthitaprajna" modal sheet.
class SharingIntentService {
  static final SharingIntentService _instance = SharingIntentService._internal();
  factory SharingIntentService() => _instance;
  SharingIntentService._internal();

  StreamSubscription<List<SharedMediaFile>>? _intentSub;
  bool _initialized = false;

  /// Initializes intent interception using the top-level application context
  void init(BuildContext context) {
    if (_initialized) return;
    _initialized = true;

    try {
      // 1. Listen for incoming shares while the app is in background/foreground
      _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen(
        (List<SharedMediaFile> files) {
          if (files.isNotEmpty && context.mounted) {
            final first = files.first;
            _processSharedFile(context, first);
            ReceiveSharingIntent.instance.reset();
          }
        },
        onError: (err) {
          debugPrint('[SharingIntentService] getMediaStream error: $err');
        },
      );

      // 2. Handle cold launch from share sheet
      ReceiveSharingIntent.instance.getInitialMedia().then((List<SharedMediaFile> files) {
        if (files.isNotEmpty && context.mounted) {
          final first = files.first;
          _processSharedFile(context, first);
          ReceiveSharingIntent.instance.reset();
        }
      }).catchError((err) {
        debugPrint('[SharingIntentService] getInitialMedia error: $err');
      });
    } catch (e) {
      debugPrint('[SharingIntentService] Platform initialization error: $e');
    }
  }

  void _processSharedFile(BuildContext context, SharedMediaFile file) {
    final path = file.path;
    final isImage = file.type == SharedMediaType.image;
    IncomingShareModalSheet.show(
      context,
      rawContent: path,
      mediaPath: isImage ? path : null,
    );
  }

  /// Manually triggers the share interceptor modal for testing or user paste
  void triggerManualShare(
    BuildContext context, {
    required String content,
    String? mediaPath,
  }) {
    IncomingShareModalSheet.show(
      context,
      rawContent: content,
      mediaPath: mediaPath,
    );
  }

  void dispose() {
    _intentSub?.cancel();
    _intentSub = null;
    _initialized = false;
  }
}
