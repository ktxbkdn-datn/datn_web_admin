import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';

import '../../../domain/entities/notification_entity.dart';

class MediaPreview extends StatefulWidget {
  final List<MediaInfo> mediaItems;
  final String baseUrl;
  final int notificationId;
  final String authToken;
  final Future<ChewieController?> Function(String, int) getChewieController;
  final Function(BuildContext, List<MediaInfo>, int, int) showFullScreenMedia;

  const MediaPreview({
    super.key,
    required this.mediaItems,
    required this.baseUrl,
    required this.notificationId,
    required this.authToken,
    required this.getChewieController,
    required this.showFullScreenMedia,
  });

  @override
  _MediaPreviewState createState() => _MediaPreviewState();
}

class _MediaPreviewState extends State<MediaPreview> {
  bool _isVideo(MediaInfo media) {
    return media.fileType == 'video';
  }

  bool _isDocument(MediaInfo media) {
    return media.fileType == 'document';
  }

  String _buildMediaUrl(String mediaPath) {
    return '${widget.baseUrl}/notification_media/$mediaPath';
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.mediaItems.asMap().entries.map((entry) {
        final index = entry.key;
        final media = entry.value;
        final mediaUrl = _buildMediaUrl(media.mediaUrl);

        if (_isDocument(media)) {
          return GestureDetector(
            onTap: () => widget.showFullScreenMedia(context, widget.mediaItems, index, widget.notificationId),
            child: Container(
              width: 225,
              height: 225,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.description, size: 80, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text(
                    media.filename,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          );
        } else if (_isVideo(media)) {
          return GestureDetector(
            onTap: () => widget.showFullScreenMedia(context, widget.mediaItems, index, widget.notificationId),
            child: FutureBuilder<ChewieController?>(
              future: widget.getChewieController(media.mediaUrl, widget.notificationId),
              builder: (context, snapshot) {
                if (!mounted) {
                  return const SizedBox.shrink(); // Prevent updates if widget is disposed
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    width: 225,
                    height: 225,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return SizedBox(
                    width: 225,
                    height: 225,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.videocam_off, size: 40, color: Colors.grey),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error?.toString() ?? 'Failed to load video',
                          style: const TextStyle(color: Colors.red, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                return ClipRect(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: SizedBox(
                      width: 225,
                      height: 225,
                      child: Chewie(controller: snapshot.data!),
                    ),
                  ),
                );
              },
            ),
          );
        }
        return GestureDetector(
          onTap: () => widget.showFullScreenMedia(context, widget.mediaItems, index, widget.notificationId),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: mediaUrl,
              width: 225,
              height: 225,
              fit: BoxFit.cover,
              httpHeaders: {'Authorization': 'Bearer ${widget.authToken}'},
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) {
                print('Failed to load image: $url, error: $error');
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 40, color: Colors.grey),
                    const SizedBox(height: 8),
                    Text(
                      'Failed to load image: $error',
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}