import 'dart:async';
import 'package:flutter/material.dart' hide Notification;
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/entities/notification_entity.dart';
import 'media_preview.dart';

// Hàm tính thời gian tương đối
String _calculateRelativeTime(String? dateTime) {
  if (dateTime == null) return 'Unknown';
  try {
    final utcDateTime = DateTime.parse(dateTime);
    final vnDateTime = utcDateTime.add(const Duration(hours: 7)); // Chuyển sang múi giờ Việt Nam
    final now = DateTime.now();
    final difference = now.difference(vnDateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} năm trước';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} tháng trước';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  } catch (e) {
    print('Error calculating relative time: $e');
    return 'Unknown';
  }
}

class NotificationItem extends StatefulWidget {
  final Notification notification;
  final Map<int, PageController> pageControllers;
  final Map<String, ChewieController> chewieControllers;
  final Map<String, VideoPlayerController> videoControllers;
  final Function(BuildContext, List<MediaInfo>, int, int) showFullScreenMedia;
  final String? Function(String?) formatDateTime;
  final String baseUrl;
  final VoidCallback? onDelete;

  const NotificationItem({
    Key? key,
    required this.notification,
    required this.pageControllers,
    required this.chewieControllers,
    required this.videoControllers,
    required this.showFullScreenMedia,
    required this.formatDateTime,
    required this.baseUrl,
    this.onDelete,
  }) : super(key: key);

  @override
  _NotificationItemState createState() => _NotificationItemState();
}

class _NotificationItemState extends State<NotificationItem> {
  Future<String?>? _authTokenFuture;
  String? _authToken;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _authTokenFuture = _loadAuthToken();
  }

  Future<String?> _loadAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    if (token == null) {
      print('Authentication token missing');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication token missing. Please log in again.'),
            backgroundColor: Colors.red,
          ),
        );
      });
    } else {
      print('Loaded auth token for NotificationItem: $token');
    }
    return token;
  }

  @override
  void dispose() {
    final notificationId = widget.notification.notificationId;
    if (notificationId != null) {
      widget.pageControllers[notificationId]?.dispose();
      widget.pageControllers.remove(notificationId);

      final urls = widget.chewieControllers.keys.toList();
      for (var url in urls) {
        if (url.contains('$notificationId')) {
          widget.chewieControllers[url]?.pause();
          widget.chewieControllers[url]?.dispose();
          widget.chewieControllers.remove(url);
          widget.videoControllers[url]?.pause();
          widget.videoControllers[url]?.dispose();
          widget.videoControllers.remove(url);
        }
      }
    }
    super.dispose();
  }

  Future<ChewieController?> _getChewieController(String url, int notificationId) async {
    if (!widget.chewieControllers.containsKey(url)) {
      final fullUrl = '${widget.baseUrl}/notification_media/$url';
      if (fullUrl.isEmpty) {
        print('Error: Full URL is empty for notification $notificationId');
        return null;
      }

      if (_authToken == null) {
        _authToken = await _authTokenFuture;
      }
      if (_authToken == null) {
        print('Error: Auth token is null, cannot load video for URL: $fullUrl');
        return null;
      }

      final videoController = VideoPlayerController.networkUrl(
        Uri.parse(fullUrl),
        httpHeaders: {'Authorization': 'Bearer $_authToken'},
      );
      widget.videoControllers[url] = videoController;

      try {
        await videoController.initialize().timeout(const Duration(seconds: 30), onTimeout: () {
          throw TimeoutException('Video initialization timeout: $fullUrl');
        });
        print('Video initialized successfully for notification $notificationId: $fullUrl');

        final chewieController = ChewieController(
          videoPlayerController: videoController,
          autoPlay: false,
          looping: false,
          allowFullScreen: true,
          showControlsOnInitialize: true,
          allowPlaybackSpeedChanging: false,
          errorBuilder: (context, errorMessage) {
            print('Chewie error for $fullUrl: $errorMessage');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    'Failed to load video: $errorMessage',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
          placeholder: const Center(child: CircularProgressIndicator()),
        );
        widget.chewieControllers[url] = chewieController;
        return chewieController;
      } catch (error, stackTrace) {
        print('Error initializing video $fullUrl for notification $notificationId: $error');
        print('Stack trace: $stackTrace');
        videoController.dispose();
        widget.videoControllers.remove(url);
        return null;
      }
    }
    return widget.chewieControllers[url];
  }

  @override
  Widget build(BuildContext context) {
    final notification = widget.notification;
    final notificationId = notification.notificationId;

    bool isGeneral = widget.notification.targetType == 'ALL';

    return FutureBuilder<String?>(
      future: _authTokenFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'Error loading authentication token: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          );
        }

        _authToken = snapshot.data;

        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Target: ${widget.notification.targetType}',
                                  style: const TextStyle(fontSize: 14, color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            notification.title ?? 'Untitled',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (widget.onDelete != null)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red, size: 28),
                        onPressed: widget.onDelete,
                        tooltip: 'Delete Notification',
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  notification.message ?? 'No content',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                      ),
                  maxLines: _isExpanded ? null : 3,
                  overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                ),
                if ((notification.message?.length ?? 0) > 100)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Text(
                      _isExpanded ? 'Thu gọn' : 'Xem thêm',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (notification.media != null && notification.media!.isNotEmpty && notificationId != null) ...[
                  const SizedBox(height: 12),
                  _authToken != null
                      ? MediaPreview(
                          mediaItems: notification.media!,
                          baseUrl: widget.baseUrl,
                          notificationId: notificationId,
                          authToken: _authToken!,
                          getChewieController: _getChewieController,
                          showFullScreenMedia: widget.showFullScreenMedia,
                        )
                      : const Center(
                          child: Text(
                            'Cannot load media: Authentication token missing',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Posted: ${_calculateRelativeTime(widget.notification.createdAt)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                    Text(
                      widget.formatDateTime(widget.notification.createdAt) ?? 'Unknown',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}