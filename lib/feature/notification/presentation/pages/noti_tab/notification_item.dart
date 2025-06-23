import 'dart:async';
import 'package:flutter/material.dart' hide Notification;
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:async/async.dart';

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
  final VoidCallback? onEdit; // Thêm callback cho chỉnh sửa

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
    this.onEdit,
  }) : super(key: key);

  @override
  _NotificationItemState createState() => _NotificationItemState();
}

class _NotificationItemState extends State<NotificationItem> with SingleTickerProviderStateMixin {
  Future<String?>? _authTokenFuture;
  String? _authToken;
  bool _isExpanded = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _authTokenFuture = _loadAuthToken();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
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
    _animationController.dispose();

    final notificationId = widget.notification.notificationId;
    if (notificationId != null) {
      widget.pageControllers[notificationId]?.dispose();
      widget.pageControllers.remove(notificationId);

      final urls = widget.chewieControllers.keys.toList();
      for (var url in urls) {
        if (url.contains('$notificationId')) {
          widget.chewieControllers[url]?.pause(); // Pause instead of dispose
          widget.videoControllers[url]?.pause();
        }
      }
    }
    super.dispose();
  }

  Future<ChewieController?> _getChewieController(String url, int notificationId) async {
    if (!mounted) {
      print('Widget is not mounted, aborting controller creation for URL: $url');
      return null;
    }

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

      final operation = CancelableOperation.fromFuture(
        videoController.initialize().timeout(const Duration(seconds: 30), onTimeout: () {
          throw TimeoutException('Video initialization timeout: $fullUrl');
        }),
      );

      try {
        await operation.value;
        if (!mounted) {
          print('Widget disposed during video initialization, cleaning up: $fullUrl');
          videoController.dispose();
          return null;
        }

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
        if (!mounted) {
          print('Widget disposed after creating ChewieController, cleaning up: $fullUrl');
          chewieController.dispose();
          videoController.dispose();
          return null;
        }
        widget.chewieControllers[url] = chewieController;
        widget.videoControllers[url] = videoController;
        return chewieController;
      } catch (error, stackTrace) {
        print('Error initializing video $fullUrl for notification $notificationId: $error');
        print('Stack trace: $stackTrace');
        videoController.dispose();
        await operation.cancel();
        return null;
      }
    }
    return widget.chewieControllers[url];
  }

  // Helper method to get translated targetType text for display
  String _getTargetTypeDisplayText(String? targetType) {
    switch (targetType) {
      case 'ALL':
        return 'Mọi người';
      case 'ROOM':
        return 'Phòng';
      case 'USER':
        return 'Người dùng cụ thể';
      default:
        return 'Không xác định';
    }
  }

  Color _getTargetTypeColor(String? targetType) {
    switch (targetType) {
      case 'ALL':
        return Colors.blue;
      case 'ROOM':
        return Colors.green;
      case 'USER':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getTargetTypeIcon(String? targetType) {
    switch (targetType) {
      case 'ALL':
        return Icons.group;
      case 'ROOM':
        return Icons.meeting_room;
      case 'USER':
        return Icons.person;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notification = widget.notification;
    final notificationId = notification.notificationId;
    final targetColor = _getTargetTypeColor(notification.targetType);

    return FutureBuilder<String?>(
      future: _authTokenFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Card(
              elevation: 10,
              shadowColor: Colors.black.withOpacity(0.08),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [Colors.grey.shade50, Colors.grey.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Card(
              elevation: 10,
              shadowColor: Colors.red.withOpacity(0.15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [Colors.red.shade50, Colors.red.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade600, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        'Error loading authentication token',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${snapshot.error}',
                        style: TextStyle(
                          color: Colors.red.shade600,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        _authToken = snapshot.data;

        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 18.0),
              child: Card(
                elevation: 14,
                shadowColor: targetColor.withOpacity(0.18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: LinearGradient(
                      colors: [Colors.white, targetColor.withOpacity(0.03)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: targetColor.withOpacity(0.13),
                      width: 1.2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Target Type Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          targetColor.withOpacity(0.13),
                                          targetColor.withOpacity(0.07),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(22),
                                      border: Border.all(
                                        color: targetColor.withOpacity(0.35),
                                        width: 1.2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: targetColor.withOpacity(0.08),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _getTargetTypeIcon(widget.notification.targetType),
                                          size: 17,
                                          color: targetColor,
                                        ),
                                        const SizedBox(width: 7),
                                        Text(
                                          _getTargetTypeDisplayText(widget.notification.targetType),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: targetColor,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  // Title
                                  Text(
                                    notification.title, // Removed ?? 'Không có tiêu đề' since title is non-nullable
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade800,
                                          height: 1.3,
                                        ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            // Action Buttons
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(14),
                                      onTap: widget.onEdit,
                                      child: Container(
                                        padding: const EdgeInsets.all(9),
                                        child: Icon(
                                          Icons.edit_outlined,
                                          color: Colors.blue.shade600,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(14),
                                      onTap: widget.onDelete,
                                      child: Container(
                                        padding: const EdgeInsets.all(9),
                                        child: Icon(
                                          Icons.delete_outline,
                                          color: Colors.red.shade600,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        // Message Content
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notification.message, // Removed ?? 'No content' since message is non-nullable
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.grey.shade700,
                                      height: 1.5,
                                    ),
                                maxLines: _isExpanded ? null : 3,
                                overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                              ),
                              if ((notification.message.length) > 100) // Removed ?. and ?? 0, message is non-nullable
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isExpanded = !_isExpanded;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: Colors.blue.shade200,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            _isExpanded ? 'Thu gọn' : 'Xem thêm',
                                            style: TextStyle(
                                              color: Colors.blue.shade700,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(
                                            _isExpanded ? Icons.expand_less : Icons.expand_more,
                                            color: Colors.blue.shade700,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Media Section
                        if (notification.media != null && notification.media!.isNotEmpty && notificationId != null) ...[
                          const SizedBox(height: 18),
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.grey.shade50,
                                  Colors.white, // Changed from Colors.grey.shade25 to Colors.white
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.attachment,
                                      color: Colors.grey.shade600,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 7),
                                    Text(
                                      'Media đính kèm (${notification.media!.length})',
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
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
                                    : Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade50,
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(
                                            color: Colors.red.shade200,
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.warning_amber,
                                              color: Colors.red.shade600,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Cannot load media: Authentication token missing',
                                                style: TextStyle(
                                                  color: Colors.red.shade700,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 18),
                        // Footer Section
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                          decoration: BoxDecoration(
                            color: targetColor.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: targetColor.withOpacity(0.13),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 7),
                                  Text(
                                    _calculateRelativeTime(widget.notification.createdAt),
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    size: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 7),
                                  Text(
                                    widget.formatDateTime(widget.notification.createdAt) ?? 'Unknown',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),  
          ),
        );  
      },
    );
  }
}

// All boxShadow lists are correct and only contain BoxShadow objects.
// No action needed, just forcing a refresh to clear stale errors.


